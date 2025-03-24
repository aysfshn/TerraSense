// login_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool isLoading = false;

  Future<void> loginUser() async {
    final url = Uri.parse(
        'http://127.0.0.1:5000/auth/giris'); // Geliştirme ortamı URL'si
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _email,
          'password': _password,
        }),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        // Giriş başarılı, token'ı SharedPreferences'e kaydedin
        final token = responseData['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);

        // MainMenuScreen'e geçiş yapın
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        );
      } else {
        // Hata mesajını gösterin
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hata'),
            content: Text(responseData['hata'] ?? 'Giriş başarısız'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tamam'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Ağ veya diğer hataları yönetin
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hata'),
          content: Text('Bir hata oluştu: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-posta'),
                onSaved: (val) => _email = val ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Lütfen e-posta girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                onSaved: (val) => _password = val ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Lütfen şifre girin';
                  }
                  if (val.length < 6) {
                    return 'Şifre en az 6 karakter olmalı';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          loginUser();
                        }
                      },
                      child: const Text('Giriş Yap'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
