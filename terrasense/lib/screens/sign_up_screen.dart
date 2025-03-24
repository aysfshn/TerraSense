import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main_menu_screen.dart'; // Kayıt başarılı olunca yönleneceğiniz ekran

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Veriler
  String _ad = '';
  String _soyad = '';
  String _email = '';
  String _password = '';
  String? _telefon; // opsiyonel, null olabilir
  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    try {
      // Flask’ta /auth/kayit endpointi çalışıyor olmalı
      final url = Uri.parse("http://127.0.0.1:5000/auth/kayit");
      // Android emülatörde => "http://10.0.2.2:5000/auth/kayit"

      // Telefon alanı boş (null veya "") olabilir diye kontrol yapıyoruz
      final Map<String, dynamic> bodyData = {
        "ad": _ad,
        "soyad": _soyad,
        "email": _email,
        "password": _password,
      };

      // Eğer telefon girildiyse ekle
      if (_telefon != null && _telefon!.isNotEmpty) {
        bodyData["telefon"] = _telefon;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 201) {
        // Kayıt başarılı (201 Created)
        final data = jsonDecode(response.body);
        // data["mesaj"] veya data["kullanici"] dönebilir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        );
      } else {
        // Hata durumu (400 / 500 vs.)
        final msg = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Kayıt hatası: ${msg['hata'] ?? response.statusCode}")),
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
        title: const Text("Üye Ol"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Ad
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ad'),
                onSaved: (val) => _ad = val ?? '',
                validator: (val) => (val == null || val.isEmpty) ? 'Ad giriniz' : null,
              ),
              // Soyad
              TextFormField(
                decoration: const InputDecoration(labelText: 'Soyad'),
                onSaved: (val) => _soyad = val ?? '',
                validator: (val) => (val == null || val.isEmpty) ? 'Soyad giriniz' : null,
              ),
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

              // Opsiyonel Telefon
              TextFormField(
                decoration: const InputDecoration(labelText: 'Telefon (opsiyonel)'),
                onSaved: (val) => _telefon = val,
              ),

              const SizedBox(height: 20),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _signUp();
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


/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'main_menu_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Değişkenler
  String _email = '';
  String _password = '';
  String _firstName = ''; // Ad
  String _lastName = '';  // Soyad

  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    try {
      // Flask/Python sunucusundaki kayıt endpointi.
      // URL'yi kendi projenize göre düzenleyin:
      final url = Uri.parse("http://127.0.0.1:5000/auth/kayit");
      // Eğer Android Emülatör'de çalışıyorsanız "10.0.2.2" yazmalısınız.
      // Flutter Web ise CORS ayarlarına dikkat etmelisiniz.

      // Gönderilecek veriyi JSON'a çeviriyoruz:
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "ad": _firstName,
          "soyad": _lastName,
          "email": _email,
          "password": _password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Başarılı kayıt
        final data = jsonDecode(response.body);
        // data içinde {"message":"..."} veya başka bilgiler olabilir
        
        // Kaydın başarıyla tamamlandığını varsayıp ana menüye geçiyoruz:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        );
      } else {
        // Hatalı cevap
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Kayıt hatası: ${response.statusCode}")),
        );
      }
    } catch (e) {
      // Ağa ulaşamama, sunucu kapalı vb.
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
        title: const Text('Üye Ol'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Ad
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ad'),
                onSaved: (val) => _firstName = val ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Lütfen ad giriniz';
                  }
                  return null;
                },
              ),
              // Soyad
              TextFormField(
                decoration: const InputDecoration(labelText: 'Soyad'),
                onSaved: (val) => _lastName = val ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Lütfen soyad giriniz';
                  }
                  return null;
                },
              ),
              // E-Posta
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-Posta'),
                onSaved: (val) => _email = val ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Lütfen e-posta giriniz';
                  }
                  // İsterseniz burada regex vb. ile format kontrolü yapabilirsiniz
                  return null;
                },
              ),
              // Şifre
              TextFormField(
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                onSaved: (val) => _password = val ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Lütfen şifre giriniz';
                  }
                  if (val.length < 6) {
                    return 'Şifre en az 6 karakter olmalı';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Kaydı Tamamla Butonu
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _signUp();
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
*/

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Flask/Python sunucudaki kayıt endpoint’i
      final url = Uri.parse("http://127.0.0.1:5000/auth/kayit"); 
      // Yerel çalışıyorsan "127.0.0.1:5000" 
      // Flutter web’de "127.0.0.1" yerine "localhost" veya CORS ayarlarına dikkat
      // Android emülatörde "10.0.2.2:5000" gerekebilir.

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": _email,
          "password": _password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Başarılı kayıt
        // Belki backend, {"message":"User created","token":"..."} gibi bir JSON gönderir
        // data["message"] veya data["token"] ile bir şey yapabilirsiniz.
        final data = jsonDecode(response.body);
        
        // Kayıt işlemi başarılı -> Ana menüye yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        );
      } else {
        // Hatalı cevap
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Kayıt hatası: ${response.statusCode}")),
        );
      }
    } catch (e) {
      // İstek atma, network sorunu vb.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // build metodunda Form
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
              // E-posta
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
              // Şifre
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
              
              // Buton
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        // Form valid mi kontrol ediyoruz
                        if (_formKey.currentState!.validate()) {
                          // Değerleri state'e kaydet
                          _formKey.currentState!.save();
                          // Sunucuya kaydı yolla
                          _signUp();
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
*/



/*
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
*/