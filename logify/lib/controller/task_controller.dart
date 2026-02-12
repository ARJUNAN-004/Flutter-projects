// lib/controllers/task_controller.dart
import 'package:flutter/material.dart';
import 'package:logify/models/task.dart';
import 'package:logify/services/database_service.dart';

class TaskController {
  final String employeeDocId;
  final DatabaseService _db = DatabaseService();

  TaskController(this.employeeDocId);

  // -------------------------------------------------------
  // STREAMS
  // -------------------------------------------------------
  Stream<List<Task>> streamPending() =>
      _db.streamTasks(employeeDocId, completed: false);

  Stream<List<Task>> streamCompleted() =>
      _db.streamTasks(employeeDocId, completed: true);

  // -------------------------------------------------------
  // TASK LIST BUILDER
  // -------------------------------------------------------
  Widget buildTaskList(BuildContext context, List<Task> tasks,
      {required bool completed}) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      itemBuilder: (context, i) {
        final t = tasks[i];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(t.title),
            subtitle: Text(t.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!completed)
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => toggleComplete(t.id, true),
                  ),
                if (completed)
                  IconButton(
                    icon: const Icon(Icons.undo, color: Colors.orange),
                    onPressed: () => toggleComplete(t.id, false),
                  ),
                if (!completed)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => showTaskDialog(context, task: t),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => confirmDelete(context, t.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------
  // MARK COMPLETE / UNCOMPLETE
  // -------------------------------------------------------
  Future<void> toggleComplete(String id, bool val) async {
    await _db.toggleTaskComplete(employeeDocId, id, val);
  }

  // -------------------------------------------------------
  // DELETE WITH CONFIRMATION
  // -------------------------------------------------------
  Future<void> confirmDelete(BuildContext context, String taskId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _db.deleteTask(employeeDocId, taskId);
    }
  }

  // -------------------------------------------------------
  // ADD / EDIT DIALOG
  // -------------------------------------------------------
  void showTaskDialog(BuildContext context, {Task? task}) {
    final titleCtrl = TextEditingController(text: task?.title ?? "");
    final descCtrl = TextEditingController(text: task?.description ?? "");

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Center(
            child: Text(
              task == null ? "Add Task" : "Edit Task",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Title",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Description",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0eb657),
              ),
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final desc = descCtrl.text.trim();

                if (title.isEmpty) return;

                if (task == null) {
                  await _db.addTask(employeeDocId, title, desc);
                } else {
                  await _db.updateTask(employeeDocId, task.id, title, desc);
                }

                Navigator.pop(dialogContext);
              },
              child: Text(task == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }
}