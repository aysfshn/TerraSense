import 'package:flutter/material.dart';
import 'dart:math';
import '../models/land.dart';

class NewLandScreen extends StatefulWidget {
  const NewLandScreen({Key? key}) : super(key: key);

  @override
  State<NewLandScreen> createState() => _NewLandScreenState();
}

class _NewLandScreenState extends State<NewLandScreen> {
  final _formKey = GlobalKey<FormState>();
  String _landName = '';
  String _location = '';
  double _budget = 0.0;
  String _selectedLandType = 'Bahçe'; // Arazi tipi dropdown varsayılanı
  String _selectedSoilAnalysis = 'Kireçli'; // Toprak analizi dropdown varsayılanı
  bool _isOtherSoilSelected = false; // Ekranda tutacağımız bir flag
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
              // ARAZİ ADI
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
              
              // KONUM
              TextFormField(
                decoration: const InputDecoration(labelText: 'Konum'),
                onSaved: (val) => _location = val ?? '',
              ),
              
              // TOPRAK ANALİZİ (DropDown)
              

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
              
// "Diğer" seçilince manuel giriş TextFormField
if (_isOtherSoilSelected)
  TextFormField(
    decoration: const InputDecoration(labelText: 'Toprak Analizi (Diğer)'),
    onSaved: (val) {
      if (_isOtherSoilSelected && val != null && val.isNotEmpty) {
        _selectedSoilAnalysis = val;
      }
    },
  ),


              // İsterseniz "Diğer" seçilince manuel giriş açılmasını sağlayabilirsiniz:
              // Ör: eğer _selectedSoilAnalysis == 'Diğer' ise ek bir TextFormField göster

              // BÜTÇE
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ayrılacak Bütçe'),
                keyboardType: TextInputType.number,
                onSaved: (val) {
                  if (val != null && val.isNotEmpty) {
                    _budget = double.tryParse(val) ?? 0.0;
                  }
                },
              ),
              
              // ARAZİ TİPİ (DropDown)
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
              
              // KAYDET BUTONU
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final newLand = Land(
                      id: Random().nextInt(100000).toString(),
                      name: _landName,
                      location: _location,
                      soilAnalysis: _selectedSoilAnalysis,
                      budget: _budget,
                      recommendedCrops: ['Buğday', 'Mısır', 'Ayçiçeği'],
                      landType: _selectedLandType,
                    );
                    Navigator.pop(context, newLand);
                  }
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
