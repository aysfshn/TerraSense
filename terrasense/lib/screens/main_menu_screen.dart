// main_menu_screen.dart
import 'package:flutter/material.dart';
import 'land_detail_screen.dart';
import 'new_land_screen.dart';
import '../models/land.dart';
import 'package:terra_sense/ApiService.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

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
      appBar: AppBar(title: const Text('Ana Menü')),
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
                          'Tip: ${land.landType} - Bakım yüzdesi: ${land.carePercentage.toStringAsFixed(1)}%',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
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
