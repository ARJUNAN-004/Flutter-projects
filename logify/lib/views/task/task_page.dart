// lib/views/task/task_screen.dart
import 'package:flutter/material.dart';
import 'package:logify/controller/task_controller.dart';
import 'package:logify/models/task.dart';

class TaskScreen extends StatefulWidget {
  final String employeeDocId;

  const TaskScreen({super.key, required this.employeeDocId});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late TaskController controller;
  int _buttonIndex = 0; // 0 => Pending, 1 => Completed

  @override
  void initState() {
    super.initState();
    controller = TaskController(widget.employeeDocId);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Tasks")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _tabButton('Pending', 0, screenWidth),
                _tabButton('Completed', 1, screenWidth),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: screenHeight - 180,
              child: _buttonIndex == 0
                  ? _buildPending()
                  : _buildCompleted(),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff0eb657),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => controller.showTaskDialog(context),
      ),
    );
  }

  // -------------------------------------------------------
  // TAB BUTTON
  // -------------------------------------------------------
  Widget _tabButton(String text, int idx, double width) {
    final active = _buttonIndex == idx;

    return InkWell(
      onTap: () => setState(() => _buttonIndex = idx),
      child: Container(
        height: 50,
        width: width / 2.2,
        decoration: BoxDecoration(
          color: active ? const Color(0xff0eb657) : Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: active ? 16 : 14,
              fontWeight: FontWeight.w500,
              color: active ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // PENDING
  // -------------------------------------------------------
  Widget _buildPending() {
    return StreamBuilder<List<Task>>(
      stream: controller.streamPending(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());

        final tasks = snap.data!;
        if (tasks.isEmpty) return const Center(child: Text("No pending tasks"));

        return controller.buildTaskList(context, tasks, completed: false);
      },
    );
  }

  // -------------------------------------------------------
  // COMPLETED
  // -------------------------------------------------------
  Widget _buildCompleted() {
    return StreamBuilder<List<Task>>(
      stream: controller.streamCompleted(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());

        final tasks = snap.data!;
        if (tasks.isEmpty) return const Center(child: Text("No completed tasks"));

        return controller.buildTaskList(context, tasks, completed: true);
      },
    );
  }
}
