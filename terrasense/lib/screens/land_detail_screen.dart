import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/land.dart';
import '../screens/task_list_screen.dart';
import 'package:terra_sense/ApiService.dart';
import '../screens/advicescreen.dart';
import '../screens/weather_screen.dart';

class LandDetailScreen extends StatefulWidget {
  final Land land;
  final Function(Land) onUpdate;

  const LandDetailScreen({
    Key? key,
    required this.land,
    required this.onUpdate,
  }) : super(key: key);

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

  Future<void> _updateLandBackend() async {
    setState(() => isUpdating = true);
    try {
      final updatedLand = await ApiService.updateLand(land);
      setState(() => land = updatedLand);
      widget.onUpdate(updatedLand);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Güncelleme hatası: $e')),
      );
    } finally {
      setState(() => isUpdating = false);
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
        setState(() => land.chosenCrop = manualCrop);
      }
    } else {
      setState(() => land.chosenCrop = selected);
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
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, input),
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    ).then((value) => result = value);
    return result;
  }

  void _takePhotoOrUpload() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fotoğraf çekildi: ${photo.path}")),
      );
      // Fotoğrafı sunucuya gönderip analiz edebilirsiniz.
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
    setState(() => land.totalIncome += income);
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

  Future<void> _getWeather() async {
    try {
      final weatherResponse = await ApiService.getWeather(land.id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              WeatherScreen(weatherData: weatherResponse['hava_durumu']),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hava durumu alınırken hata oluştu: $e')),
      );
    }
  }

  Future<void> _getAdvice() async {
    try {
      final adviceData = await ApiService.getAdvice(land.id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdviceScreen(adviceData: adviceData),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tavsiye alınırken hata oluştu: $e')),
      );
    }
  }

  void _editAdditionalDetails() {
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
    final recentProductsController = TextEditingController(
      text: land.recentProducts ?? '',
    );
    final issuesController = TextEditingController(
      text: land.issues ?? '',
    );
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
                  decoration:
                      const InputDecoration(labelText: 'Sulama Kaynağı'),
                ),
                TextField(
                  controller: irrigationMethodController,
                  decoration:
                      const InputDecoration(labelText: 'Sulama Yöntemi'),
                ),
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
                  decoration:
                      const InputDecoration(labelText: 'Çalışan Sayısı'),
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
                  land.size = double.tryParse(sizeController.text);
                  land.landStructure = landStructureController.text;
                  land.soilColor = soilColorController.text;
                  land.soilComposition = soilCompositionController.text;
                  land.stoneStatus = stoneStatusController.text;
                  land.waterStatus = waterStatusController.text;
                  land.irrigationSource = irrigationSourceController.text;
                  land.irrigationMethod = irrigationMethodController.text;
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
      // Arka plan gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F8E9), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isUpdating
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Arazi temel bilgileri kartı
                    Card(
                      color: Colors.white.withOpacity(0.85),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Konum: ${land.location}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Toprak Analizi: ${land.soilAnalysis}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Bütçe: ${land.budget}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Butonlar (ürün seç, görevler, fotoğraf vb.)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.agriculture),
                          label: Text(
                            land.chosenCrop == null
                                ? 'Ürün Seç/Değiştir'
                                : 'Seçili Ürün: ${land.chosenCrop}',
                          ),
                          onPressed: _selectCrop,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.list),
                          label: const Text('Sulama/Gübreleme Görevleri'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskListScreen(
                                  land: land,
                                  onUpdate: (updatedLand) {
                                    setState(() => land = updatedLand);
                                    _updateLandBackend();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Hasat Kontrol Fotoğrafı'),
                          onPressed: _takePhotoOrUpload,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.cloud),
                          label: const Text('Hava Durumu'),
                          onPressed: _getWeather,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.help_outline),
                          label: const Text('Tavsiye Al'),
                          onPressed: _getAdvice,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Ek bilgiler
                    Card(
                      color: Colors.white.withOpacity(0.85),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ek Bilgiler',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (land.size != null)
                              Text(
                                  'Büyüklük: ${land.size} ${land.sizeUnit ?? ''}'),
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
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text('Ek Bilgileri Düzenle'),
                              onPressed: _editAdditionalDetails,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Gider / Gelir işlemleri
                    Card(
                      color: Colors.white.withOpacity(0.85),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  label: const Text('Gider Ekle'),
                                  onPressed: _showExpenseDialog,
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('Gelir Ekle'),
                                  onPressed: _showIncomeDialog,
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.attach_money),
                                  label: const Text('Kâr Marjını Göster'),
                                  onPressed: _calculateProfitMargin,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Toplam Gider: ${land.totalExpense}'),
                            Text('Toplam Gelir: ${land.totalIncome}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
