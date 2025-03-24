import 'package:flutter/material.dart';
import '../models/land.dart';
import 'package:terra_sense/ApiService.dart';

class NewLandScreen extends StatefulWidget {
  const NewLandScreen({Key? key}) : super(key: key);

  @override
  State<NewLandScreen> createState() => _NewLandScreenState();
}

class _NewLandScreenState extends State<NewLandScreen> {
  final _formKey = GlobalKey<FormState>();

  // Zorunlu alanlar
  String _landName = '';
  String _location = '';
  double _budget = 0.0;
  String _selectedLandType = 'Bahçe';
  String _selectedSoilAnalysis = 'Kireçli';
  bool _isOtherSoilSelected = false;

  // Ek alanlar (daha önce ekledikleriniz)
  double? _size;
  String? _selectedSizeUnit;
  String? _selectedLandStructure;
  String? _soilColor;
  String? _selectedSoilComposition;
  String? _selectedStoneStatus;
  String? _selectedWaterStatus;
  String? _selectedIrrigationSource;
  String? _selectedIrrigationMethod;

  // **Yeni eklemek istediğiniz alanlar** (son_urunler, sorunlar, ekipmanlar, calisan_sayisi, don_durumlari)
  String? _recentProducts; // son_urunler
  String? _issues; // sorunlar
  String? _equipments; // ekipmanlar
  int? _employeeCount; // calisan_sayisi
  String? _frostStatuses; // don_durumlari

  bool isSubmitting = false;

  // Örnek dropdown listeleri (daha önce kullandıklarınız)
  final List<String> _sizeUnits = ['Dönüm', 'Hektar'];
  final List<String> _landStructures = ['Düz', 'Hafif eğimli', 'Çok engebeli'];
  final List<String> _soilCompositions = ['Kumlu', 'Tınlı', 'Killi'];
  final List<String> _stoneStatuses = ['Az taşlı', 'Çok taşlı', 'Taşsız'];
  final List<String> _waterStatuses = [
    'Çabuk su çeker',
    'Uzun süre su kalır',
    'Normal'
  ];
  final List<String> _irrigationSources = [
    'Kuyu',
    'Nehir',
    'Baraj',
    'Yağmur suyu',
    'Sulama yapılmıyor'
  ];
  final List<String> _irrigationMethods = [
    'Damla sulama',
    'Yağmurlama',
    'Salma sulama',
    'Sulama yapılmıyor'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Arazi Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Arazi Adı
              TextFormField(
                decoration: const InputDecoration(labelText: 'Arazi Adı'),
                onSaved: (val) => _landName = val ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Arazi adı giriniz';
                  }
                  return null;
                },
              ),
              // Konum
              TextFormField(
                decoration: const InputDecoration(labelText: 'Konum'),
                onSaved: (val) => _location = val ?? '',
              ),
              // Toprak Analizi (DropDown)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Toprak Analizi'),
                value: _selectedSoilAnalysis,
                items: [
                  'Kireçli',
                  'Killi',
                  'Kumlu',
                  'Humuslu',
                  'Diğer',
                ].map((soilType) {
                  return DropdownMenuItem<String>(
                    value: soilType,
                    child: Text(soilType),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSoilAnalysis = val ?? 'Kireçli';
                    _isOtherSoilSelected = (val == 'Diğer');
                  });
                },
              ),
              if (_isOtherSoilSelected)
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Toprak Analizi (Diğer)'),
                  onSaved: (val) {
                    if (_isOtherSoilSelected && val != null && val.isNotEmpty) {
                      _selectedSoilAnalysis = val;
                    }
                  },
                ),
              // Bütçe
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ayrılacak Bütçe'),
                keyboardType: TextInputType.number,
                onSaved: (val) {
                  if (val != null && val.isNotEmpty) {
                    _budget = double.tryParse(val) ?? 0.0;
                  }
                },
              ),
              // Arazi Tipi (DropDown)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Arazi Tipi'),
                value: _selectedLandType,
                items: [
                  'Bahçe',
                  'Tarla',
                  'Sera',
                  'Saksı',
                  'Diğer',
                ].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedLandType = val ?? 'Bahçe';
                  });
                },
              ),
              const SizedBox(height: 20),
              const Divider(),
              const Text('Ek Bilgiler',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

              // Büyüklük
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Büyüklük (örn. 5.5)'),
                keyboardType: TextInputType.number,
                onSaved: (val) {
                  if (val != null && val.isNotEmpty) {
                    _size = double.tryParse(val);
                  }
                },
              ),
              // Büyüklük Birimi
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Büyüklük Birimi'),
                value: _selectedSizeUnit,
                items: _sizeUnits.map((unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSizeUnit = val;
                  });
                },
              ),
              // Arazi Yapısı
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Arazi Yapısı'),
                value: _selectedLandStructure,
                items: _landStructures.map((structure) {
                  return DropdownMenuItem<String>(
                    value: structure,
                    child: Text(structure),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedLandStructure = val;
                  });
                },
              ),
              // Toprak Rengi
              TextFormField(
                decoration: const InputDecoration(labelText: 'Toprak Rengi'),
                onSaved: (val) => _soilColor = val,
              ),
              // Toprak Yapısı
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Toprak Yapısı'),
                value: _selectedSoilComposition,
                items: _soilCompositions.map((composition) {
                  return DropdownMenuItem<String>(
                    value: composition,
                    child: Text(composition),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSoilComposition = val;
                  });
                },
              ),
              // Taş Durumu
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Taş Durumu'),
                value: _selectedStoneStatus,
                items: _stoneStatuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedStoneStatus = val;
                  });
                },
              ),
              // Su Durumu
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Su Durumu'),
                value: _selectedWaterStatus,
                items: _waterStatuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedWaterStatus = val;
                  });
                },
              ),
              // Sulama Kaynağı
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Sulama Kaynağı'),
                value: _selectedIrrigationSource,
                items: _irrigationSources.map((source) {
                  return DropdownMenuItem<String>(
                    value: source,
                    child: Text(source),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedIrrigationSource = val;
                  });
                },
              ),
              // Sulama Yöntemi
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Sulama Yöntemi'),
                value: _selectedIrrigationMethod,
                items: _irrigationMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedIrrigationMethod = val;
                  });
                },
              ),
              const SizedBox(height: 20),

              // **Eklemek istediğiniz yeni alanlar:**
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Son Ürünler (Örn. Buğday, Mısır)'),
                onSaved: (val) => _recentProducts = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Sorunlar'),
                onSaved: (val) => _issues = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ekipmanlar'),
                onSaved: (val) => _equipments = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Çalışan Sayısı'),
                keyboardType: TextInputType.number,
                onSaved: (val) {
                  if (val != null && val.isNotEmpty) {
                    _employeeCount = int.tryParse(val);
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Don Durumları'),
                onSaved: (val) => _frostStatuses = val,
              ),

              const SizedBox(height: 20),
              isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Kaydet'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      isSubmitting = true;
    });

    // Yeni arazi nesnesini oluşturun
    final newLand = Land(
      id: '', // Backend oluşturduğunda id dönecek
      name: _landName,
      location: _location,
      soilAnalysis: _selectedSoilAnalysis,
      budget: _budget,
      landType: _selectedLandType,
      size: _size,
      sizeUnit: _selectedSizeUnit,
      landStructure: _selectedLandStructure,
      soilColor: _soilColor,
      soilComposition: _selectedSoilComposition,
      stoneStatus: _selectedStoneStatus,
      waterStatus: _selectedWaterStatus,
      irrigationSource: _selectedIrrigationSource,
      irrigationMethod: _selectedIrrigationMethod,

      // Finansal
      totalExpense: 0,
      totalIncome: 0,

      // Yeni eklediğimiz alanlar:
      recentProducts: _recentProducts, // son_urunler
      issues: _issues, // sorunlar
      equipments: _equipments, // ekipmanlar
      employeeCount: _employeeCount, // calisan_sayisi
      frostStatuses: _frostStatuses, // don_durumlari

      // Frontend'e özel
      carePercentage: 0,
      recommendedCrops: const [],
      tasks: const [],
    );

    try {
      final createdLand = await ApiService.createLand(newLand);
      Navigator.pop(context, createdLand);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arazi oluşturulamadı: $e')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }
}
