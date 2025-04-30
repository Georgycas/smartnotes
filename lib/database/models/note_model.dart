/// 📘 Note model for SmartNotes app
class Note {
  final String id;
  final String? title;
  final String? content;
  final String? label;
  final String? userId;      // Multi-user support
  final String? firebaseId;  // Optional Firebase sync
  final DateTime createdAt;
  final DateTime updatedAt;

  /// ⚡ Runtime-only: set of media types like 'image', 'recording']
  final Set<String> mediaTypes;

  Note({
    required this.id,
    this.title,
    this.content,
    this.label,
    this.userId,
    this.firebaseId,
    required this.createdAt,
    required this.updatedAt,
    this.mediaTypes = const {},
  });

  /// 🔁 Convert Note to DB Map (excluding runtime-only fields)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'label': label,
      'user_id': userId,
      'firebase_id': firebaseId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 🔁 Create Note from DB Map (mediaTypes passed optionally)
  static Note fromMap(Map<String, dynamic> map, {Set<String> mediaTypes = const {}}) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      label: map['label'],
      userId: map['user_id'],
      firebaseId: map['firebase_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      mediaTypes: mediaTypes,
    );
  }

  /// 🧪 Create copy of Note with optional overrides
  Note copyWith({
    String? title,
    String? content,
    String? label,
    String? userId,
    String? firebaseId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Set<String>? mediaTypes,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      label: label ?? this.label,
      userId: userId ?? this.userId,
      firebaseId: firebaseId ?? this.firebaseId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mediaTypes: mediaTypes ?? this.mediaTypes,
    );
  }

  /// 📦 Generate metadata map for metadata table
  Map<String, dynamic> toMetadataMap(String parentId) {
    return {
      'parent_id': parentId,
      'is_deleted': 0,
      'is_archived': 0,
      'sync_status': 'local',
      'last_synced_at': null,
    };
  }
}

/// 🎞️ Media model for associated note media (images, recordings)
class Media {
  final String id;
  final String parentId;
  final String parentType; // Always "note" in this app
  final String filePath;
  final String mediaType; // "image", "recording", etc.

  Media({
    required this.id,
    required this.parentId,
    required this.parentType,
    required this.filePath,
    required this.mediaType,
  });

  /// 🔁 Convert Media to DB Map
  Map<String, dynamic> toMap() => {
        'id': id,
        'parent_id': parentId,
        'parent_type': parentType,
        'file_path': filePath,
        'media_type': mediaType,
      };

  /// 🔁 Create Media from DB Map
  static Media fromMap(Map<String, dynamic> map) => Media(
        id: map['id'],
        parentId: map['parent_id'],
        parentType: map['parent_type'],
        filePath: map['file_path'],
        mediaType: map['media_type'],
      );
}
