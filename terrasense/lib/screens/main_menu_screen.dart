import 'package:flutter/material.dart';
import 'land_detail_screen.dart';
import '../models/land.dart';
import 'new_land_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  // Örnek veri listesi
  List<Land> lands = [];

  void _addLand(Land newLand) {
    setState(() {
      lands.add(newLand);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Menü'),
      ),
      body: lands.isEmpty
          ? const Center(
              child: Text('Henüz arazi eklemediniz.'),
            )
          : ListView.builder(
              itemCount: lands.length,
              itemBuilder: (context, index) {
                final land = lands[index];
                return Card(
                  child: ListTile(
                    title: Text(land.name),
                    subtitle: Text(
                      'Tip: ${land.landType} - Bakım yüzdesi: ${land.carePercentage.toStringAsFixed(1)}%',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LandDetailScreen(
                            land: land,
                            onUpdate: (updatedLand) {
                              setState(() {
                                lands[index] = updatedLand;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),

                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newLand = await Navigator.push<Land?>(
            context,
            MaterialPageRoute(builder: (_) => const NewLandScreen()),
          );
          if (newLand != null) {
            _addLand(newLand);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
