import 'package:flutter/material.dart';

class WeatherScreen extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherScreen({Key? key, required this.weatherData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hava durumu verileri
    final nem = weatherData['nem']?.toString() ?? '-';
    final ruzgarHizi = weatherData['ruzgar_hizi']?.toString() ?? '-';
    final sicaklik = weatherData['sicaklik']?.toString() ?? '-';
    final genelHava = weatherData['genel_hava'] ?? 'Bilinmiyor';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hava Durumu'),
        centerTitle: true,
      ),
      body: Container(
        // Arkaplanda gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF87CEFA), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Dikeyde ortalayalım
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Başlık veya genel hava durumu
            Text(
              genelHava,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 20),

            // Sıcaklık Kartı
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white.withOpacity(0.8),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.thermostat, color: Colors.redAccent),
                title: Text(
                  'Sıcaklık',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('$sicaklik °C'),
              ),
            ),
            const SizedBox(height: 10),

            // Nem Kartı
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white.withOpacity(0.8),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.opacity, color: Colors.blueAccent),
                title: const Text(
                  'Nem Oranı',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('$nem %'),
              ),
            ),
            const SizedBox(height: 10),

            // Rüzgar Kartı
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white.withOpacity(0.8),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.air, color: Colors.green),
                title: const Text(
                  'Rüzgar Hızı',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('$ruzgarHizi m/s'),
              ),
            ),
            const SizedBox(height: 20),

            // Alt açıklama veya ek bilgiler
            const Text(
              'Güncel hava durumu bilgileri',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
