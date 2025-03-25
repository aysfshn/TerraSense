import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool isLoading = false;

  Future<void> loginUser() async {
    final url = Uri.parse('http://127.0.0.1:5000/auth/giris');
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': _email, 'password': _password}),
      );
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final token = responseData['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);

        // Ana menüye yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainMenuScreen(
              onThemeChanged: (ThemeMode newTheme) {},
            ),
          ),
        );
      } else {
        // Hata mesajını göster
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
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
        centerTitle: true,
      ),
      body: Container(
        // Arka planı gradient yapıyoruz
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          // Kartı dikeyde ortalamak için
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // İçeriğe göre boyutlansın
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
                      const SizedBox(height: 20),

                      // Giriş Yap Butonu
                      isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              icon: const Icon(Icons.login),
                              label: const Text('Giriş Yap'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  loginUser();
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
