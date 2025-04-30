import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'database/db_helper.dart';
import 'database/operations/system_operations.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize DB
  await DBHelper.instance.database;

  // Insert anonymous/null user if none exists
  final user = await SystemOperations.getCurrentUser();
  if (user == null) {
    final newUser = {
      'id': const Uuid().v4(),
      'username': null,
      'email': null,
      'profile_picture': null,
      'firebase_uid': null,
      'created_at': DateTime.now().toIso8601String(),
      'last_login': DateTime.now().toIso8601String(),
    };
    await SystemOperations.upsertUser(newUser);
    await SystemOperations.markSetupComplete();
  }

  // Launch directly into the app
  runApp(const SmartNotes());
}

