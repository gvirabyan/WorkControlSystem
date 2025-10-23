import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/task_model.dart' as model;

class AllTasksPage extends StatefulWidget {
  final String userId;

  const AllTasksPage({super.key, required this.userId});

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  bool showCompleted = false;

  void _showAddTaskDialog() {
    // Твоя логика добавления задачи
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Tasks')),
      body: Column(
        children: [
          // Switch и кнопка Add Task
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Show Completed Tasks'),
                    Switch(
                      value: showCompleted,
                      onChanged: (val) {
                        setState(() {
                          showCompleted = val;
                        });
                      },
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showAddTaskDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .collection('tasks')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data!.docs
                    .map((doc) => model.Task.fromMap(doc.id, doc.data()))
                    .where((task) {
                  if (showCompleted) {
                    return task.status.toLowerCase() == 'completed';
                  } else {
                    return task.status.toLowerCase() != 'completed';
                  }
                })
                    .toList();

                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks to show.'));
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final t = tasks[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(t.title),
                        subtitle: Text(
                          'Description: ${t.description}\n'
                              'Status: ${t.status}\n'
                              'Start: ${t.startDate} - End: ${t.endDate}\n'
                              'Due: ${t.dueDate}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}