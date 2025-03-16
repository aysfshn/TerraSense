import 'package:flutter/material.dart';
import '../models/land.dart';
import 'task_list_screen.dart';
import 'package:image_picker/image_picker.dart'; // fotoğraf yükleme örneği için

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

  @override
  void initState() {
    super.initState();
    land = widget.land;
  }

 


  void _selectCrop() async {
    // Kullanıcıya önerilen ürün listesini gösteren bir basit dialog
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
          // Kullanıcı istediği ürünü yoksa manuel girmesi için:
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'manual'),
            child: const Text('Listede yok, kendim gireyim.'),
          )
        ],
      ),
    );

    if (selected == null) return;

    if (selected == 'manual') {
      // Kullanıcıdan manuel ürün girmesini iste
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
    widget.onUpdate(land);
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
    // Örnek olarak ImagePicker ile fotoğraf alınabilir. 
    // Bu fotoğraf “hasat vakti geldi mi?” gibi bir yapay zeka modeline gönderilebilir.
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      // Fotoğraf seçildi. Sunucuya gönderilip “hasat yapabilir mi?” analizi yaptırılabilir.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fotoğraf çekildi: ${photo.path}")),
      );
    }
  }

  void _updateExpenses(double expense) {
    setState(() {
      land.totalExpense += expense;
      // Bakım yüzdesini örnek olarak masrafla biraz ilişkilendirebiliriz
      land.carePercentage += 3; 
    });
    widget.onUpdate(land);
  }

  void _updateIncome(double income) {
    setState(() {
      land.totalIncome += income;
    });
    widget.onUpdate(land);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(land.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
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
                // Görev listesine git (sulama, gübreleme vb.)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskListScreen(
                      land: land,
                      onUpdate: (updatedLand) {
                        setState(() {
                          land = updatedLand;
                        });
                        widget.onUpdate(land);
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
            // Gider/Gelir ve Kar marjı hesaplama butonları
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showExpenseDialog();
                    },
                    child: const Text('Gider Ekle'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showIncomeDialog();
                    },
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
}
