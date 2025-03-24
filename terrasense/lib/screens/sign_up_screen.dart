import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For encoding/decoding JSON
import 'main_menu_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _ad = ''; // Add other necessary fields like "ad" and "soyad"
  String _soyad = '';

  Future<void> registerUser() async {
    final url = Uri.parse(
      'http://127.0.0.1:5000/auth/kayit',
    ); // Replace with your actual backend URL

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _email,
          'password': _password,
          'ad': _ad,
          'soyad': _soyad,
        }),
      );

      if (response.statusCode == 201) {
        // Registration successful, navigate to the main menu
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        );
      } else {
        // Handle error responses (e.g., show an alert)
        final responseData = json.decode(response.body);
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Hata'),
                content: Text(responseData['hata'] ?? 'Kayıt işlemi başarısız'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Tamam'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      print('Error: $e');
      // Handle network or other errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Üye Ol')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ad'),
                onSaved: (val) => _ad = val ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Soyad'),
                onSaved: (val) => _soyad = val ?? '',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    registerUser(); // Call the register function
                  }
                },
                child: const Text('Kaydı Tamamla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
