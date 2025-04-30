import 'dart:io';
import '../db_helper.dart';
import '../models/note_model.dart';

class NoteOperations {
  static const String table = 'notes';
  static const String metadataTable = 'metadata';
  static const String mediaTable = 'media';

  /// ✅ Batch insert or replace
  static Future<void> insertNotesBatch(List<Note> notes) async {
    await DBHelper.batchInsert(table, notes.map((n) => n.toMap()).toList());

    await DBHelper.batchInsert(
      metadataTable,
      notes.map((n) => n.toMetadataMap(n.id)).toList(),
    );
  }

  /// ✅ Batch update (when trigger is tripped)
  static Future<void> updateNotesBatch(List<Note> notes) async {
    await DBHelper.batchUpdate(
      table,
      notes.map((n) => n.toMap()).toList(),
      'id',
    );
  }

  /// 🗃 Soft archive (single item)
  static Future<void> archiveNote(Note note) async {
    await DBHelper.batchUpdate(metadataTable, [
      {'parent_id': note.id, 'is_archived': 1, 'sync_status': 'local'},
    ], 'parent_id');
  }

  /// 🗑 Soft delete (move to trash)
  static Future<void> trashNote(Note note) async {
    await DBHelper.batchUpdate(metadataTable, [
      {'parent_id': note.id, 'is_deleted': 1, 'sync_status': 'local'},
    ], 'parent_id');
  }

  /// ❌ Full delete (note + media + metadata)
  static Future<void> deleteNoteCompletely(String noteId) async {
    final db = await DBHelper.instance.database;
    await db.delete(mediaTable, where: 'parent_id = ?', whereArgs: [noteId]);
    await db.delete(metadataTable, where: 'parent_id = ?', whereArgs: [noteId]);
    await db.delete(table, where: 'id = ?', whereArgs: [noteId]);
  }

  /// ✅ Load all active (non-deleted, non-archived)
  static Future<List<Note>> getActiveNotes() async {
    final db = await DBHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT $table.*, $metadataTable.is_deleted, $metadataTable.is_archived
      FROM $table
      LEFT JOIN $metadataTable ON $table.id = $metadataTable.parent_id
      WHERE $metadataTable.is_deleted = 0 AND $metadataTable.is_archived = 0
    ''');

    return result.map((e) => Note.fromMap(e)).toList();
  }

  /// 🗃️ Get archived notes
  static Future<List<Note>> getArchivedNotes() async {
    final db = await DBHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT notes.*, metadata.is_deleted, metadata.is_archived
      FROM notes
      LEFT JOIN metadata ON notes.id = metadata.parent_id
      WHERE metadata.is_archived = 1 AND metadata.is_deleted = 0
    ''');
    return result.map((e) => Note.fromMap(e)).toList();
  }

  /// ♻️ Restore from archive
  static Future<void> restoreNotesBatch(List<Note> notes) async {
    await DBHelper.batchUpdate(
      'metadata',
      notes
          .map(
            (note) => {
              'parent_id': note.id,
              'is_archived': 0,
              'sync_status': 'local',
            },
          )
          .toList(),
      'parent_id',
    );
  }

  /// 🗑 Move to trash (from archive or not)
  static Future<void> trashNotesBatch(List<Note> notes) async {
    await DBHelper.batchUpdate(
      'metadata',
      notes
          .map(
            (note) => {
              'parent_id': note.id,
              'is_deleted': 1,
              'sync_status': 'local',
            },
          )
          .toList(),
      'parent_id',
    );
  }

  /// 🗑️ Get trashed notes
  static Future<List<Note>> getTrashedNotes() async {
    final db = await DBHelper.instance.database;
    final result = await db.rawQuery('''
    SELECT notes.*, metadata.is_deleted, metadata.is_archived
    FROM notes
    LEFT JOIN metadata ON notes.id = metadata.parent_id
    WHERE metadata.is_deleted = 1
  ''');
    return result.map((e) => Note.fromMap(e)).toList();
  }

  static Future<void> permanentlyDeleteNotesBatch(List<Note> notes) async {
    final db = await DBHelper.instance.database;
    final batch = db.batch();

    for (final note in notes) {
      // 🗃 Get linked media files
      final mediaList = await db.query(
        'media',
        where: 'parent_id = ? AND parent_type = ?',
        whereArgs: [note.id, 'note'],
      );

      // ❌ Delete each media file from storage
      for (final media in mediaList) {
        final filePath = media['file_path'] as String;
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // 🧹 Delete media records
      batch.delete('media', where: 'parent_id = ?', whereArgs: [note.id]);

      // ❌ Delete metadata + note
      batch.delete('metadata', where: 'parent_id = ?', whereArgs: [note.id]);
      batch.delete('notes', where: 'id = ?', whereArgs: [note.id]);
    }

    await batch.commit(noResult: true);
  }

  /// 📷🎙 Get media for a note (typed)
  static Future<List<Media>> getMediaForNote(String noteId) async {
    final db = await DBHelper.instance.database;
    final result = await db.query(
      mediaTable,
      where: 'parent_id = ? AND parent_type = ?',
      whereArgs: [noteId, 'note'],
    );
    return result.map((e) => Media.fromMap(e)).toList();
  }

  static Future<void> insertMediaBatch(List<Media> mediaList) async {
    if (mediaList.isEmpty) return;

    await DBHelper.batchInsert(
      mediaTable,
      mediaList.map((m) => m.toMap()).toList(),
    );
  }

}
