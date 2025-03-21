import 'package:flutter/material.dart';
import 'package:terra_sense/screens/login_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hoş Geldiniz!',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Toprağın ve iklimin şifresini çözüyoruz!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Üye Ol butonu
            ElevatedButton(
              onPressed: () {
                // Üye Ol ekranına yönlendir
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                );
              },
              child: const Text('Üye Ol'),
            ),

            // Giriş Yap butonu
            TextButton(
              onPressed: () {
                // Giriş ekranına yönlendir
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Hesabınız var mı? Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
