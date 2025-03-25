// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/land.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000'; // Geliştirme ortamınız

  // Her istek öncesi SharedPreferences üzerinden token'ı okur ve header'ı oluşturur.
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? "";
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Arazileri çekerken URL sonuna eğik çizgi ekleyin:
  static Future<List<Land>> fetchLands() async {
    final url = Uri.parse('$baseUrl/arazi/');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List landsJson = data['araziler'];
      return landsJson.map((json) => Land.fromJson(json)).toList();
    } else {
      throw Exception(
        'Araziler getirilemedi. Status Code: ${response.statusCode}',
      );
    }
  }

  // Yeni arazi oluştururken ek alanlar dahil gönderiliyor:
  static Future<Land> createLand(Land land) async {
    final url = Uri.parse('$baseUrl/arazi/');
    final headers = await _getHeaders();

    final bodyData = {
      'adi': land.name,
      'konum': land.location,
      'toprak_analizi': land.soilAnalysis,
      'butce': land.budget,
      'arazi_tipi': land.landType,
      'buyukluk': land.size,
      'buyukluk_birimi': land.sizeUnit,
      'arazi_yapisi': land.landStructure,
      'toprak_rengi': land.soilColor,
      'toprak_yapisi': land.soilComposition,
      'tas_durumu': land.stoneStatus,
      'su_durumu': land.waterStatus,
      'sulama_kaynagi': land.irrigationSource,
      'sulama_yontemi': land.irrigationMethod,
      'son_urunler': land.recentProducts, // eklendi
      'sorunlar': land.issues, // eklendi
      'ekipmanlar': land.equipments, // eklendi
      'calisan_sayisi': land.employeeCount, // eklendi
      'don_durumlari': land.frostStatuses, // eklendi
      'toplam_gider': land.totalExpense,
      'toplam_gelir': land.totalIncome,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(bodyData),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Land.fromJson(data['arazi']);
    } else {
      throw Exception(
        'Arazi oluşturulamadı. Status Code: ${response.statusCode}',
      );
    }
  }

  static Future<Land> updateLand(Land land) async {
    final url = Uri.parse('$baseUrl/arazi/${land.id}/');
    final headers = await _getHeaders();

    // Land.toJson() kullanabilirsiniz veya direkt bodyData oluşturabilirsiniz:
    final bodyData =
        land.toJson(); // Bu toJson içinde bu alanların da olması gerekiyor

    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(bodyData),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Land.fromJson(data['arazi']);
    } else {
      throw Exception(
        'Arazi güncellenemedi. Status Code: ${response.statusCode}',
      );
    }
  }

  static Future<void> deleteLand(String landId) async {
    final url = Uri.parse(
        '$baseUrl/arazi/$landId'); // Örneğin: http://127.0.0.1:5000/arazi/5
    final headers = await _getHeaders();

    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
          'Arazi silinirken hata oluştu. Status Code: ${response.statusCode}');
    }
  }
}
