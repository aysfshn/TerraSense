class Land {
  String id;
  String name;
  String location;
  String soilAnalysis;
  double budget;
  double carePercentage;
  List<String> recommendedCrops;
  String? chosenCrop;
  double totalExpense;
  double totalIncome;
  List<TaskItem> tasks;

  // YENİ ALAN:
  String landType; // "Bahçe", "Tarla", "Sera" vb.

  Land({
    required this.id,
    required this.name,
    required this.location,
    required this.soilAnalysis,
    required this.budget,
    this.carePercentage = 0.0,
    this.recommendedCrops = const [],
    this.chosenCrop,
    this.totalExpense = 0.0,
    this.totalIncome = 0.0,
    this.tasks = const [],
    this.landType = 'Bahçe', // Varsayılan olabilir
  });
}

class TaskItem {
  String taskName;
  bool isDone;

  TaskItem({
    required this.taskName,
    this.isDone = false,
  });
}
