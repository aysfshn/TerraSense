import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Üye Ol'),
      ),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Burada kayıt işlemini yaparsınız, DB veya API'ye yollama vb.
                    // Başarılı olursa ana menüye yönlendirin:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                    );
                  }
                },
                child: const Text('Kaydı Tamamla'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
