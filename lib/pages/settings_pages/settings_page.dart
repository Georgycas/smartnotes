import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          _buildNavigationTile(context, 'General', '/settings/general'),
          _buildNavigationTile(context, 'Notifications', '/settings/notifications'),
          _buildNavigationTile(context, 'Security & Privacy', '/settings/security'),
          _buildNavigationTile(context, 'Backup & Sync', '/settings/backup'),
          _buildNavigationTile(context, 'App Info', '/settings/app_info'),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
