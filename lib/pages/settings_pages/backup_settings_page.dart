import 'package:flutter/material.dart';

class BackupSettingsPage extends StatefulWidget {
  const BackupSettingsPage({super.key});

  @override
  BackupSettingsPageState createState() => BackupSettingsPageState();
}

class BackupSettingsPageState extends State<BackupSettingsPage> {
  bool _cloudSyncEnabled = true;
  String _backupFrequency = 'Daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Backup & Sync')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Enable Cloud Sync'),
            value: _cloudSyncEnabled,
            onChanged: (value) {
              setState(() => _cloudSyncEnabled = value);
            },
          ),
          ListTile(
            title: Text('Backup Frequency'),
            trailing: DropdownButton<String>(
              value: _backupFrequency,
              onChanged: (value) {
                setState(() => _backupFrequency = value!);
              },
              items: ['Daily', 'Weekly', 'Monthly'].map((freq) {
                return DropdownMenuItem(value: freq, child: Text(freq));
              }).toList(),
            ),
          ),
          ListTile(
            title: Text('Manual Backup'),
            trailing: Icon(Icons.backup),
            onTap: () {
              // Placeholder for manual backup logic
            },
          ),
          ListTile(
            title: Text('Restore from Backup'),
            trailing: Icon(Icons.restore),
            onTap: () {
              // Placeholder for restore backup logic
            },
          ),
        ],
      ),
    );
  }
}