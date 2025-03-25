import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AdviceScreen extends StatelessWidget {
  final Map<String, dynamic> adviceData;

  const AdviceScreen({Key? key, required this.adviceData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // API'den dönen tavsiye metni:
    String adviceText = adviceData['tavsiyeler'] ?? 'Tavsiye bulunamadı.';

    // İsterseniz metin üzerinde küçük düzenlemeler yapabilirsiniz.
    // Örneğin, "-" ile başlayan satırları "* " yaparak Markdown bullet haline getirebilirsiniz:
    // adviceText = adviceText.replaceAll('\n- ', '\n* ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arazi Tavsiyesi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Markdown widget'ı ile tavsiye metnini zengin biçimde gösteriyoruz.
        child: Markdown(
          data: adviceText,
          styleSheet: MarkdownStyleSheet(
            h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            p: const TextStyle(fontSize: 16),
            listBullet: const TextStyle(fontSize: 16, color: Colors.green),
            // Daha fazla stil özelleştirmesi yapabilirsiniz
          ),
          onTapLink: (text, url, title) {
            // Eğer tavsiye metninde link varsa, tıklandığında ne yapacağınızı belirtebilirsiniz.
          },
        ),
      ),
    );
  }
}
