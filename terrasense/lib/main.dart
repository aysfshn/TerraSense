import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const TerraSenseApp());
}

class TerraSenseApp extends StatelessWidget {
  const TerraSenseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TerraSense',
      theme: ThemeData(
        primarySwatch: Colors.green,      // Yeşil tonlar
        scaffoldBackgroundColor: Colors.grey[200], // Arka planı hafif gri
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,  // Buton rengi
            textStyle: const TextStyle(color: Colors.white),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        // vb. ek özelleştirme yapılabilir
      ),
      home: const WelcomeScreen(),
    );
  }
}
