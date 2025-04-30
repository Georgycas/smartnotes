import '../db_helper.dart';
import 'package:sqflite/sqflite.dart';

class SystemOperations {
  static const String userTable = 'users';
  static const String settingsTable = 'settings';

  // ─────────────────────────────────────────────────────────────
  // 🧑 USER OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// ✅ Insert or update a user
  static Future<void> upsertUser(Map<String, dynamic> user) async {
    final db = await DBHelper.instance.database;
    await db.insert(
      userTable,
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 🔁 Get most recently logged-in user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final db = await DBHelper.instance.database;
    final result = await db.query(
      userTable,
      orderBy: 'last_login DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// 🧪 Check if a user exists
  static Future<bool> userExists(String userId) async {
    final db = await DBHelper.instance.database;
    final result = await db.query(
      userTable,
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// ⏱ Update last login timestamp
  static Future<void> updateLastLogin(String userId) async {
    final db = await DBHelper.instance.database;
    await db.update(
      userTable,
      {'last_login': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// ❌ Soft delete (log audit-style deletion)
  static Future<void> markUserDeleted(String userId) async {
    final db = await DBHelper.instance.database;
    await db.update(
      userTable,
      {'last_login': 'deleted_${DateTime.now().toIso8601String()}'},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// 🔥 Full delete
  static Future<void> deleteUser(String userId) async {
    final db = await DBHelper.instance.database;
    await db.delete(userTable, where: 'id = ?', whereArgs: [userId]);
  }

  // ─────────────────────────────────────────────────────────────
  // ⚙️ SETTINGS OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// ✅ Save or update a setting
  static Future<void> saveSetting(String key, String value) async {
    final db = await DBHelper.instance.database;
    await db.insert(
      settingsTable,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 🔁 Retrieve a setting by key
  static Future<String?> getSetting(String key) async {
    final db = await DBHelper.instance.database;
    final result = await db.query(
      settingsTable,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return result.isNotEmpty ? result.first['value'] as String : null;
  }

  /// ✅ Check if a setting exists
  static Future<bool> settingExists(String key) async {
    final db = await DBHelper.instance.database;
    final result = await db.query(
      settingsTable,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// ❌ Delete a setting
  static Future<void> deleteSetting(String key) async {
    final db = await DBHelper.instance.database;
    await db.delete(settingsTable, where: 'key = ?', whereArgs: [key]);
  }

  /// ✅ Mark setup complete (for onboarding control)
  static Future<void> markSetupComplete() async {
    await saveSetting('setup_complete', 'true');
  }

  /// 🔁 Check if setup is complete
  static Future<bool> isSetupComplete() async {
    final value = await getSetting('setup_complete');
    return value == 'true';
  }
}
