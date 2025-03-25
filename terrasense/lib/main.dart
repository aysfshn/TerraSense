// main.dart
import 'package:flutter/material.dart';
import 'screens/main_menu_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/welcome_screen.dart'; // Eğer WelcomeScreen yerine doğrudan MainMenuScreen kullanmak isterseniz, ona göre güncelleyin.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final themeString = prefs.getString('themeMode') ?? 'system';
  ThemeMode initialThemeMode;
  if (themeString == 'light') {
    initialThemeMode = ThemeMode.light;
  } else if (themeString == 'dark') {
    initialThemeMode = ThemeMode.dark;
  } else {
    initialThemeMode = ThemeMode.system;
  }
  runApp(TerraSenseApp(initialThemeMode: initialThemeMode));
}

class TerraSenseApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  const TerraSenseApp({Key? key, required this.initialThemeMode})
      : super(key: key);

  @override
  State<TerraSenseApp> createState() => _TerraSenseAppState();
}

class _TerraSenseAppState extends State<TerraSenseApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void _updateTheme(ThemeMode newThemeMode) async {
    setState(() {
      _themeMode = newThemeMode;
    });
    final prefs = await SharedPreferences.getInstance();
    if (newThemeMode == ThemeMode.light) {
      await prefs.setString('themeMode', 'light');
    } else if (newThemeMode == ThemeMode.dark) {
      await prefs.setString('themeMode', 'dark');
    } else {
      await prefs.setString('themeMode', 'system');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TerraSense',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[200],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            textStyle: const TextStyle(color: Colors.white),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      themeMode: _themeMode,
      home: WelcomeScreen(onThemeChanged: _updateTheme),
    );
  }
}
