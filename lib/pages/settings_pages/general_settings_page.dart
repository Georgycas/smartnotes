import 'package:flutter/material.dart';

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  GeneralSettingsPageState createState() => GeneralSettingsPageState();
}

class GeneralSettingsPageState extends State<GeneralSettingsPage> {
  bool _darkMode = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('General Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
            },
          ),
          ListTile(
            title: Text('Language'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
              },
              items: ['English', 'Spanish', 'French'].map((lang) {
                return DropdownMenuItem(value: lang, child: Text(lang));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
