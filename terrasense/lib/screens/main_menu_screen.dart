import 'package:flutter/material.dart';
import 'land_detail_screen.dart';
import 'new_land_screen.dart';
import '../models/land.dart';
import 'package:terra_sense/ApiService.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'settings_screen.dart'; // Ayarlar ekranı dosyası

class MainMenuScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged; // Tema değiştirme callback'i

  const MainMenuScreen({Key? key, required this.onThemeChanged})
      : super(key: key);

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  List<Land> lands = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLands();
  }

  Future<void> _fetchLands() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedLands = await ApiService.fetchLands();
      setState(() {
        lands = fetchedLands;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Araziler alınamadı: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateLand(Land updatedLand, int index) {
    setState(() {
      lands[index] = updatedLand;
    });
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Ayarlar ekranına yönlendiriyoruz
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    currentTheme:
                        Theme.of(context).brightness == Brightness.dark
                            ? ThemeMode.dark
                            : ThemeMode.light,
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : lands.isEmpty
              ? const Center(child: Text('Henüz arazi eklemediniz.'))
              : ListView.builder(
                  itemCount: lands.length,
                  itemBuilder: (context, index) {
                    final land = lands[index];
                    return Card(
                      child: ListTile(
                        title: Text(land.name),
                        subtitle: Text(
                            'Bakım yüzdesi: ${land.carePercentage.toStringAsFixed(1)}%'),
                        trailing: CircularPercentIndicator(
                          radius: 20.0,
                          lineWidth: 4.0,
                          percent: land.carePercentage / 100,
                          center: Text(
                              "${land.carePercentage.toStringAsFixed(0)}%"),
                          progressColor: Colors.lightBlue,
                          backgroundColor: Colors.blue[900]!,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LandDetailScreen(
                                land: land,
                                onUpdate: (updated) =>
                                    _updateLand(updated, index),
                              ),
                            ),
                          );
                          if (result == 'deleted') {
                            setState(() {
                              lands.removeAt(index);
                            });
                          } else if (result is Land) {
                            _updateLand(result, index);
                          }
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
