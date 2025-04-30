import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'schemas/db_note_schema.dart';
import 'schemas/db_system_schema.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smartnote.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, filePath);

  final db = await openDatabase(
    path,
    version: 1,
    onCreate: _createDB,
    onUpgrade: _upgradeDB,
  );

  // ✅ Enable foreign key support (must be done after opening DB)
  await db.execute('PRAGMA foreign_keys = ON');

  return db;
}

  Future _createDB(Database db, int version) async {
    for (var query in [
      ...NoteSchema.createTables,
      ...SystemSchema.createTables,
    ]) {
      await db.execute(query);
    }
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Optional: Add your upgrade logic here
  }

  static Future<void> batchInsert(String table, List<Map<String, dynamic>> rows) async {
    final db = await DBHelper.instance.database;
    final batch = db.batch();
    for (var row in rows) {
      batch.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> batchUpdate(
    String table,
    List<Map<String, dynamic>> rows,
    String keyColumn,
  ) async {
    final db = await DBHelper.instance.database;
    final batch = db.batch();
    for (var row in rows) {
      batch.update(table, row, where: '$keyColumn = ?', whereArgs: [row[keyColumn]]);
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smartnote.db');
    await deleteDatabase(path);
  }

  /// ✅ Check if the database file exists (for init decision)
  Future<bool> checkIfDatabaseExists() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smartnote.db');
    return databaseExists(path);
  }

  /// ✅ Get unsynced rows from a table (e.g. notes or metadata)
  Future<List<Map<String, dynamic>>> getItemsPendingSync(String table) async {
    final db = await database;
    return await db.query(
      table,
      where: 'sync_status != ?',
      whereArgs: ['synced'],
    );
  }

  /// ✅ Mark a row as synced (by ID)
  Future<void> markAsSynced(String table, String idColumn, String idValue) async {
    final db = await database;
    await db.update(
      table,
      {
        'sync_status': 'synced',
        'last_synced_at': DateTime.now().toIso8601String(),
      },
      where: '$idColumn = ?',
      whereArgs: [idValue],
    );
  }
}
