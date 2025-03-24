// land_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/land.dart';
import '../screens/task_list_screen.dart';
import 'package:terra_sense/ApiService.dart';

class LandDetailScreen extends StatefulWidget {
  final Land land;
  final Function(Land) onUpdate;

  const LandDetailScreen({Key? key, required this.land, required this.onUpdate})
      : super(key: key);

  @override
  State<LandDetailScreen> createState() => _LandDetailScreenState();
}

class _LandDetailScreenState extends State<LandDetailScreen> {
  late Land land;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    land = widget.land;
  }

  // Seçilen değişiklikleri backend'e gönderir
  Future<void> _updateLandBackend() async {
    setState(() {
      isUpdating = true;
    });
    try {
      final updatedLand = await ApiService.updateLand(land);
      setState(() {
        land = updatedLand;
      });
      widget.onUpdate(updatedLand);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Güncelleme hatası: $e')));
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  void _selectCrop() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Ürün Seçimi'),
        children: [
          ...land.recommendedCrops.map((crop) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, crop),
              child: Text(crop),
            );
          }).toList(),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'manual'),
            child: const Text('Listede yok, kendim gireyim.'),
          ),
        ],
      ),
    );

    if (selected == null) return;

    if (selected == 'manual') {
      String? manualCrop = await _showManualInputDialog();
      if (manualCrop != null && manualCrop.trim().isNotEmpty) {
        setState(() {
          land.chosenCrop = manualCrop;
        });
      }
    } else {
      setState(() {
        land.chosenCrop = selected;
      });
    }
    _updateLandBackend();
  }

  Future<String?> _showManualInputDialog() async {
    String? result;
    await showDialog(
      context: context,
      builder: (_) {
        String input = '';
        return AlertDialog(
          title: const Text('Manuel Ürün Girişi'),
          content: TextField(
            onChanged: (val) => input = val,
            decoration: const InputDecoration(hintText: 'Ürün adı'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, input);
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    ).then((value) => result = value);
    return result;
  }

  void _takePhotoOrUpload() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fotoğraf çekildi: ${photo.path}")),
      );
      // Fotoğraf sunucuya gönderilip analiz edilebilir.
    }
  }

  void _updateExpenses(double expense) {
    setState(() {
      land.totalExpense += expense;
      land.carePercentage += 3;
    });
    _updateLandBackend();
  }

  void _updateIncome(double income) {
    setState(() {
      land.totalIncome += income;
    });
    _updateLandBackend();
  }

  void _calculateProfitMargin() {
    final profit = land.totalIncome - land.totalExpense;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kâr Marjı'),
        content: Text('Kâr Marjınız: $profit'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Ek alanları düzenleme diyalog fonksiyonu
  void _editAdditionalDetails() {
    // Existing controllers
    final sizeController = TextEditingController(
      text: land.size?.toString() ?? '',
    );
    final landStructureController = TextEditingController(
      text: land.landStructure ?? '',
    );
    final soilColorController = TextEditingController(
      text: land.soilColor ?? '',
    );
    final soilCompositionController = TextEditingController(
      text: land.soilComposition ?? '',
    );
    final stoneStatusController = TextEditingController(
      text: land.stoneStatus ?? '',
    );
    final waterStatusController = TextEditingController(
      text: land.waterStatus ?? '',
    );
    final irrigationSourceController = TextEditingController(
      text: land.irrigationSource ?? '',
    );
    final irrigationMethodController = TextEditingController(
      text: land.irrigationMethod ?? '',
    );

    // New fields
    final recentProductsController = TextEditingController(
      text: land.recentProducts ?? '',
    );
    final issuesController = TextEditingController(text: land.issues ?? '');
    final equipmentsController = TextEditingController(
      text: land.equipments ?? '',
    );
    final employeeCountController = TextEditingController(
      text: land.employeeCount != null ? land.employeeCount.toString() : '',
    );
    final frostStatusesController = TextEditingController(
      text: land.frostStatuses ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ek Bilgileri Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Existing fields
                TextField(
                  controller: sizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Büyüklük'),
                ),
                TextField(
                  controller: landStructureController,
                  decoration: const InputDecoration(labelText: 'Arazi Yapısı'),
                ),
                TextField(
                  controller: soilColorController,
                  decoration: const InputDecoration(labelText: 'Toprak Rengi'),
                ),
                TextField(
                  controller: soilCompositionController,
                  decoration: const InputDecoration(labelText: 'Toprak Yapısı'),
                ),
                TextField(
                  controller: stoneStatusController,
                  decoration: const InputDecoration(labelText: 'Taş Durumu'),
                ),
                TextField(
                  controller: waterStatusController,
                  decoration: const InputDecoration(labelText: 'Su Durumu'),
                ),
                TextField(
                  controller: irrigationSourceController,
                  decoration: const InputDecoration(
                    labelText: 'Sulama Kaynağı',
                  ),
                ),
                TextField(
                  controller: irrigationMethodController,
                  decoration: const InputDecoration(
                    labelText: 'Sulama Yöntemi',
                  ),
                ),
                // New fields
                TextField(
                  controller: recentProductsController,
                  decoration: const InputDecoration(labelText: 'Son Ürünler'),
                ),
                TextField(
                  controller: issuesController,
                  decoration: const InputDecoration(labelText: 'Sorunlar'),
                ),
                TextField(
                  controller: equipmentsController,
                  decoration: const InputDecoration(labelText: 'Ekipmanlar'),
                ),
                TextField(
                  controller: employeeCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Çalışan Sayısı',
                  ),
                ),
                TextField(
                  controller: frostStatusesController,
                  decoration: const InputDecoration(labelText: 'Don Durumları'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Existing fields
                  land.size = double.tryParse(sizeController.text);
                  land.landStructure = landStructureController.text;
                  land.soilColor = soilColorController.text;
                  land.soilComposition = soilCompositionController.text;
                  land.stoneStatus = stoneStatusController.text;
                  land.waterStatus = waterStatusController.text;
                  land.irrigationSource = irrigationSourceController.text;
                  land.irrigationMethod = irrigationMethodController.text;
                  // New fields
                  land.recentProducts = recentProductsController.text;
                  land.issues = issuesController.text;
                  land.equipments = equipmentsController.text;
                  land.employeeCount =
                      int.tryParse(employeeCountController.text);
                  land.frostStatuses = frostStatusesController.text;
                });

                _updateLandBackend();
                Navigator.pop(context);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  // Silme işlemini başlatan fonksiyon
  Future<void> _deleteLand() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Araziyi Sil'),
        content: const Text('Bu araziyi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            child: const Text('İptal'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text('Sil'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteLand(land.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arazi silindi.')),
        );
        Navigator.pop(context, 'deleted');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silme hatası: $e')),
        );
      }
    }
  }

  void _showExpenseDialog() async {
    double expense = 0.0;
    await showDialog(
      context: context,
      builder: (_) {
        String input = '';
        return AlertDialog(
          title: const Text('Gider Ekle'),
          content: TextField(
            onChanged: (val) => input = val,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Gider miktarı'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                expense = double.tryParse(input) ?? 0.0;
                Navigator.pop(context);
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
    if (expense > 0) {
      _updateExpenses(expense);
    }
  }

  void _showIncomeDialog() async {
    double income = 0.0;
    await showDialog(
      context: context,
      builder: (_) {
        String input = '';
        return AlertDialog(
          title: const Text('Gelir Ekle'),
          content: TextField(
            onChanged: (val) => input = val,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Gelir miktarı'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                income = double.tryParse(input) ?? 0.0;
                Navigator.pop(context);
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
    if (income > 0) {
      _updateIncome(income);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(land.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteLand,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isUpdating
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  Text('Konum: ${land.location}'),
                  Text('Toprak Analizi: ${land.soilAnalysis}'),
                  Text('Bütçe: ${land.budget}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _selectCrop,
                    child: Text(
                      land.chosenCrop == null
                          ? 'Ürün Seç/Değiştir'
                          : 'Seçili Ürün: ${land.chosenCrop}',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskListScreen(
                            land: land,
                            onUpdate: (updatedLand) {
                              setState(() {
                                land = updatedLand;
                              });
                              _updateLandBackend();
                            },
                          ),
                        ),
                      );
                    },
                    child: const Text('Sulama/Gübreleme Görevleri'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _takePhotoOrUpload,
                    child: const Text('Hasat Kontrol Fotoğrafı'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ek Bilgiler',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (land.size != null)
                    Text('Büyüklük: ${land.size} ${land.sizeUnit ?? ''}'),
                  if (land.landStructure != null)
                    Text('Arazi Yapısı: ${land.landStructure}'),
                  if (land.soilColor != null)
                    Text('Toprak Rengi: ${land.soilColor}'),
                  if (land.soilComposition != null)
                    Text('Toprak Yapısı: ${land.soilComposition}'),
                  if (land.stoneStatus != null)
                    Text('Taş Durumu: ${land.stoneStatus}'),
                  if (land.waterStatus != null)
                    Text('Su Durumu: ${land.waterStatus}'),
                  if (land.irrigationSource != null)
                    Text('Sulama Kaynağı: ${land.irrigationSource}'),
                  if (land.irrigationMethod != null)
                    Text('Sulama Yöntemi: ${land.irrigationMethod}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _editAdditionalDetails,
                    child: const Text('Ek Bilgileri Düzenle'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _showExpenseDialog,
                          child: const Text('Gider Ekle'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _showIncomeDialog,
                          child: const Text('Gelir Ekle'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _calculateProfitMargin,
                    child: const Text('Kâr Marjını Göster'),
                  ),
                  const SizedBox(height: 10),
                  Text('Toplam Gider: ${land.totalExpense}'),
                  Text('Toplam Gelir: ${land.totalIncome}'),
                ],
              ),
      ),
    );
  }
}
