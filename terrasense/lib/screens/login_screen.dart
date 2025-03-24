import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main_menu_screen.dart'; // Giriş başarılı olunca yönleneceğiniz ekran

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String _email = '';
  String _password = '';

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      // Flask’ta /auth/giris endpointi
      final url = Uri.parse("http://127.0.0.1:5000/auth/giris");
      // Android Emülatör -> "http://10.0.2.2:5000/auth/giris"

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": _email,
          "password": _password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        );
      } else {
        final msg = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Giriş hatası: ${msg['hata'] ?? response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giriş Yap"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // E-Posta
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-posta'),
                onSaved: (val) => _email = val ?? '',
                validator: (val) => (val == null || val.isEmpty) ? 'E-posta giriniz' : null,
              ),
              // Şifre
              TextFormField(
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                onSaved: (val) => _password = val ?? '',
                validator: (val) => (val == null || val.isEmpty) ? 'Şifre giriniz' : null,
              ),
              const SizedBox(height: 20),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _login();
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
