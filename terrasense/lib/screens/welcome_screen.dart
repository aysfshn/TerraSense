import 'package:flutter/material.dart';
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
            TextButton(
              onPressed: () {
                // Giriş yapma akışı (varsa ayrı bir login ekranı açabilirsiniz)
                // Şimdilik direkt anamenüye geçebiliriz.
                // Navigator.push(context, MaterialPageRoute(builder: (_) => const MainMenuScreen()));
              },
              child: const Text('Hesabınız var mı? Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
