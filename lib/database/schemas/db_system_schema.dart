class SystemSchema {
  static const String userTable = 'users';
  static const String settingsTable = 'settings';

  static List<String> get createTables => [
        '''
        CREATE TABLE $userTable (
          id TEXT PRIMARY KEY,
          username TEXT,
          profile_picture TEXT,
          email TEXT,
          firebase_uid TEXT,             -- For Firebase Auth (optional)
          created_at TEXT,
          last_login TEXT
        );
        ''',
        '''
        CREATE TABLE $settingsTable (
          key TEXT PRIMARY KEY,
          value TEXT
        );
        '''
      ];
}
