import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  NotificationSettingsPageState createState() => NotificationSettingsPageState();
}

class NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Enable Notifications'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          SwitchListTile(
            title: Text('Enable Sound'),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
            },
          ),
          SwitchListTile(
            title: Text('Enable Vibration'),
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() => _vibrationEnabled = value);
            },
          ),
          ListTile(
            title: Text('Notification Tone'),
            trailing: Icon(Icons.music_note),
            onTap: () {
              // Placeholder for selecting notification tone
            },
          ),
          ListTile(
            title: Text('Do Not Disturb Mode'),
            trailing: Icon(Icons.do_not_disturb),
            onTap: () {
              // Placeholder for DND settings
            },
          ),
        ],
      ),
    );
  }
}