import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:terra_sense/screens/welcome_screen.dart';
import 'dart:convert'; // For encoding/decoding JSON

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _ad = '';
  String _soyad = '';

  Future<void> registerUser() async {
    final url = Uri.parse('http://127.0.0.1:5000/auth/kayit');

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
        // Kayıt başarılı, WelcomeScreen'e yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      } else {
        // Hata durumunda uyarı
        final responseData = json.decode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hata'),
            content: Text(responseData['hata'] ?? 'Kayıt işlemi başarısız'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tamam'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Ağ veya diğer hataları yönetin
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Üye Ol'),
        centerTitle: true,
      ),
      body: Container(
        // Arka plan gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFECB3), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // içeriğe göre boyutlan
                    children: [
                      // E-posta
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'E-posta',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onSaved: (val) => _email = val ?? '',
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Lütfen e-posta girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Şifre
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
                      const SizedBox(height: 16),

                      // Ad
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Ad',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onSaved: (val) => _ad = val ?? '',
                      ),
                      const SizedBox(height: 16),

                      // Soyad
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Soyad',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onSaved: (val) => _soyad = val ?? '',
                      ),
                      const SizedBox(height: 20),

                      // Kaydı Tamamla Butonu
                      ElevatedButton.icon(
                        icon: const Icon(Icons.person_add),
                        label: const Text('Kaydı Tamamla'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            registerUser();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
