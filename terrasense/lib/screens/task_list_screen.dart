import 'package:flutter/material.dart';
import 'package:terra_sense/ApiService.dart';
import '../models/land.dart';

class TaskListScreen extends StatefulWidget {
  final Land land;
  final Function(Land) onUpdate;

  const TaskListScreen({Key? key, required this.land, required this.onUpdate})
      : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Land land;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    land = widget.land;
  }

  // Not: Görevler backend'e gönderilmeyecek, sadece yerel state güncellenecek.
  void _toggleTask(int index) {
    setState(() {
      land.tasks[index].isDone = !land.tasks[index].isDone;
      if (land.tasks[index].isDone) {
        land.carePercentage += 5;
      } else {
        land.carePercentage -= 5;
      }
    });
    // Parent widget'e güncellemeyi bildiriyoruz.
    widget.onUpdate(land);
  }

  void _addTask(String taskName) {
    setState(() {
      land.tasks.add(TaskItem(taskName: taskName));
    });
    widget.onUpdate(land);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Görevler')),
      body: isUpdating
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: land.tasks.length,
              itemBuilder: (context, index) {
                final task = land.tasks[index];
                return CheckboxListTile(
                  title: Text(task.taskName),
                  value: task.isDone,
                  onChanged: (val) {
                    _toggleTask(index);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? newTask = await _showAddTaskDialog();
          if (newTask != null && newTask.isNotEmpty) {
            _addTask(newTask);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> _showAddTaskDialog() async {
    String taskName = '';
    return showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Yeni Görev Ekle'),
          content: TextField(
            onChanged: (val) => taskName = val,
            decoration: const InputDecoration(hintText: 'Görev adı'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, taskName),
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }
}
