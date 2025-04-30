class NoteSchema {
  static const String noteTable = 'notes';
  static const String mediaTable = 'media';
  static const String metadataTable = 'metadata';

  static List<String> get createTables => [
        '''
        CREATE TABLE $noteTable (
          id TEXT PRIMARY KEY,
          title TEXT,
          content TEXT,
          label TEXT,   
          user_id TEXT,             -- For Firebase Auth support
          firebase_id TEXT,         -- For Firestore doc mapping
          created_at TEXT,
          updated_at TEXT
        );
        ''',
        '''
        CREATE TABLE $mediaTable (
          id TEXT PRIMARY KEY,
          parent_id TEXT,
          parent_type TEXT,         -- Always 'note' (but future-proofed)
          file_path TEXT,
          media_type TEXT,
          FOREIGN KEY(parent_id) REFERENCES $noteTable(id) ON DELETE CASCADE
        );
        ''',
        '''
        CREATE TABLE $metadataTable (
          parent_id TEXT PRIMARY KEY,
          is_deleted INTEGER DEFAULT 0,
          is_archived INTEGER DEFAULT 0,
          sync_status TEXT DEFAULT 'local',
          last_synced_at TEXT,
          FOREIGN KEY(parent_id) REFERENCES $noteTable(id) ON DELETE CASCADE
        );
        '''
      ];
}
