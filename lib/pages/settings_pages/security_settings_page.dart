import 'package:flutter/material.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  SecuritySettingsPageState createState() => SecuritySettingsPageState();
}

class SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _biometricLockEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Security & Privacy')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Enable Biometric Lock'),
            value: _biometricLockEnabled,
            onChanged: (value) {
              setState(() => _biometricLockEnabled = value);
            },
          ),
          ListTile(
            title: Text('Change PIN/Password'),
            trailing: Icon(Icons.vpn_key),
            onTap: () {
              // Placeholder for changing PIN/Password
            },
          ),
          ListTile(
            title: Text('Manage App Permissions'),
            trailing: Icon(Icons.security),
            onTap: () {
              // Placeholder for managing app permissions
            },
          ),
          ListTile(
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.policy),
            onTap: () {
              // Placeholder for privacy policy details
            },
          ),
        ],
      ),
    );
  }
}
