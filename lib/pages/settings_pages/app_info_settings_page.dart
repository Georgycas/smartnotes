import 'package:flutter/material.dart';

class AppInfoSettingsPage extends StatelessWidget {
  const AppInfoSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App Info')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'), // Placeholder for actual version
          ),
          ListTile(
            title: Text('About Us'),
            trailing: Icon(Icons.info),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          ListTile(
            title: Text('Terms & Privacy Policy'),
            trailing: Icon(Icons.policy),
            onTap: () {
              // Placeholder for Terms & Privacy Policy page
            },
          ),
          ListTile(
            title: Text('Open Source Licenses'),
            trailing: Icon(Icons.code),
            onTap: () {
              // Placeholder for open-source licenses
            },
          ),
        ],
      ),
    );
  }
}