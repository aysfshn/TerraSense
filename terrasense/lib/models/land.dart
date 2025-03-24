// land.dart
class Land {
  String id;
  int? userId; // Yeni alan: Backend: 'kullanici_id'
  String name; // Backend: 'adi'
  String location; // Backend: 'konum'
  String soilAnalysis; // Backend: 'toprak_analizi'
  double budget; // Backend: 'butce'
  String landType; // Backend: 'arazi_tipi'
  double? size; // Backend: 'buyukluk'
  String? sizeUnit; // Backend: 'buyukluk_birimi'
  String? landStructure; // Backend: 'arazi_yapisi'
  String? soilColor; // Backend: 'toprak_rengi'
  String? soilComposition; // Backend: 'toprak_yapisi'
  String? stoneStatus; // Backend: 'tas_durumu'
  String? waterStatus; // Backend: 'su_durumu'
  String? irrigationSource; // Backend: 'sulama_kaynagi'
  String? irrigationMethod; // Backend: 'sulama_yontemi'
  String? recentProducts; // Backend: 'son_urunler'
  String? issues; // Backend: 'sorunlar'
  String? equipments; // Backend: 'ekipmanlar'
  int? employeeCount; // Backend: 'calisan_sayisi'
  String? frostStatuses; // Backend: 'don_durumlari'
  double totalExpense; // Backend: 'toplam_gider'
  double totalIncome; // Backend: 'toplam_gelir'

  // Frontend'e özgü ek alanlar:
  double carePercentage;
  List<String> recommendedCrops;
  String? chosenCrop;
  List<TaskItem> tasks;

  // Opsiyonel tarih bilgileri:
  DateTime? createdAt; // Backend: 'olusturulma_tarihi'
  DateTime? updatedAt; // Backend: 'guncelleme_tarihi'

  Land({
    required this.id,
    this.userId,
    required this.name,
    required this.location,
    required this.soilAnalysis,
    required this.budget,
    required this.landType,
    this.size,
    this.sizeUnit,
    this.landStructure,
    this.soilColor,
    this.soilComposition,
    this.stoneStatus,
    this.waterStatus,
    this.irrigationSource,
    this.irrigationMethod,
    this.recentProducts,
    this.issues,
    this.equipments,
    this.employeeCount,
    this.frostStatuses,
    required this.totalExpense,
    required this.totalIncome,
    this.carePercentage = 0.0,
    this.recommendedCrops = const [],
    this.chosenCrop,
    this.tasks = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Land.fromJson(Map<String, dynamic> json) {
    return Land(
      id: json['id'].toString(),
      userId: json['kullanici_id'], // Yeni alan
      name: json['adi'] as String,
      location: json['konum'] as String,
      soilAnalysis: json['toprak_analizi'] as String,
      budget: (json['butce'] as num).toDouble(),
      landType: json['arazi_tipi'] as String,
      size: json['buyukluk'] != null
          ? (json['buyukluk'] as num).toDouble()
          : null,
      sizeUnit: json['buyukluk_birimi'] as String?,
      landStructure: json['arazi_yapisi'] as String?,
      soilColor: json['toprak_rengi'] as String?,
      soilComposition: json['toprak_yapisi'] as String?,
      stoneStatus: json['tas_durumu'] as String?,
      waterStatus: json['su_durumu'] as String?,
      irrigationSource: json['sulama_kaynagi'] as String?,
      irrigationMethod: json['sulama_yontemi'] as String?,
      recentProducts: json['son_urunler'] as String?,
      issues: json['sorunlar'] as String?,
      equipments: json['ekipmanlar'] as String?,
      employeeCount: json['calisan_sayisi'] as int?,
      frostStatuses: json['don_durumlari'] as String?,
      totalExpense: (json['toplam_gelir'] != null
          ? (json['toplam_gelir'] as num).toDouble()
          : 0.0),
      totalIncome: (json['toplam_gider'] != null
          ? (json['toplam_gider'] as num).toDouble()
          : 0.0),
      carePercentage: (json['carePercentage'] as num?)?.toDouble() ?? 0.0,
      recommendedCrops: json['recommendedCrops'] != null
          ? List<String>.from(json['recommendedCrops'])
          : [],
      chosenCrop: json['chosenCrop'] as String?,
      tasks: json['tasks'] != null
          ? (json['tasks'] as List).map((e) => TaskItem.fromJson(e)).toList()
          : [],
      createdAt: json['olusturulma_tarihi'] != null
          ? DateTime.tryParse(json['olusturulma_tarihi'])
          : null,
      updatedAt: json['guncelleme_tarihi'] != null
          ? DateTime.tryParse(json['guncelleme_tarihi'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kullanici_id':
          userId, // İsteğe bağlı: backend bu bilgiyi token ile de belirleyebilir.
      'adi': name,
      'konum': location,
      'toprak_analizi': soilAnalysis,
      'butce': budget,
      'arazi_tipi': landType,
      'buyukluk': size,
      'buyukluk_birimi': sizeUnit,
      'arazi_yapisi': landStructure,
      'toprak_rengi': soilColor,
      'toprak_yapisi': soilComposition,
      'tas_durumu': stoneStatus,
      'su_durumu': waterStatus,
      'sulama_kaynagi': irrigationSource,
      'sulama_yontemi': irrigationMethod,
      'son_urunler': recentProducts,
      'sorunlar': issues,
      'ekipmanlar': equipments,
      'calisan_sayisi': employeeCount,
      'don_durumlari': frostStatuses,
      'toplam_gider': totalExpense,
      'toplam_gelir': totalIncome,
      // Frontend'e özgü alanlar backend'e gönderilmez.
    };
  }
}

class TaskItem {
  String taskName;
  bool isDone;

  TaskItem({
    required this.taskName,
    this.isDone = false,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      taskName: json['taskName'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskName': taskName,
      'isDone': isDone,
    };
  }
}
