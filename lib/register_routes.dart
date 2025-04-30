import 'package:flutter/material.dart';
import 'register_book.dart'; // Export your screens here
import 'package:smartnotes/database/models/note_model.dart';

class AppRoutes {
  // ─────────── Setup & Auth ───────────
  static const String userSetup = '/setup';
  static const String login = '/login';

  // ─────────── Core Pages ───────────
  static const String home = '/notes';
  static const String archive = '/archive';
  static const String trash = '/trash';
  static const String vault = '/vault';

  // ─────────── Settings ───────────
  static const String settings = '/settings';
  static const String general = '/settings/general';
  static const String notifications = '/settings/notifications';
  static const String security = '/settings/security';
  static const String backup = '/settings/backup';
  static const String appInfo = '/settings/app_info';

  // ─────────── Editor Page ───────────
  static const String noteEditor = '/note_editor';

  // ─────────── Route Map ───────────
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      userSetup: (context) => const UserSetupScreen(),
      login: (context) => const LoginScreen(),
      home: (context) => const NotePage(),
      archive: (context) => const ArchivePage(),
      trash: (context) => const TrashPage(),
      vault: (context) => const VaultPage(),
      settings: (context) => const SettingsPage(),
      general: (context) => const GeneralSettingsPage(),
      notifications: (context) => const NotificationSettingsPage(),
      security: (context) => const SecuritySettingsPage(),
      backup: (context) => const BackupSettingsPage(),
      appInfo: (context) => const AppInfoSettingsPage(),
      noteEditor: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Note) {
          return NoteEditorPage(note: args); // ✅ Editing existing note
        } else if (args is Map<String, dynamic>) {
          return NoteEditorPage(
            widgetType: args['widgetType'] ?? 'text',
          ); // ✅ Quick Add from FAB
        } else {
          return const NoteEditorPage(); // fallback
        }
      },
    };
  }
}
