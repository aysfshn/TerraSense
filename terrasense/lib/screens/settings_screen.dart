import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;

  const SettingsScreen({
    Key? key,
    required this.currentTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: Column(
        children: [
          const ListTile(
            title: Text('Tema Seçimi'),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Açık Tema'),
            value: ThemeMode.light,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) onThemeChanged(value);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Koyu Tema'),
            value: ThemeMode.dark,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) onThemeChanged(value);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Sistem Ayarı'),
            value: ThemeMode.system,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) onThemeChanged(value);
            },
          ),
        ],
      ),
    );
  }
}
