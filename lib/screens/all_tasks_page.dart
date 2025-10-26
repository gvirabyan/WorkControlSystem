import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/task_model.dart' as model;

class AllTasksPage extends StatefulWidget {
  final String userId;

  const AllTasksPage({super.key, required this.userId});

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  bool showCompleted = false;



  Future<void> _showAddTaskDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final statusController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final dueDateController = TextEditingController();

    Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      }
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('add_task')),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.translate('title'),
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.translate('description'),
                ),
              ),
              TextField(
                controller: statusController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.translate('status'),
                ),
              ),
              GestureDetector(
                onTap: () => _selectDate(context, startDateController),
                child: AbsorbPointer(
                  child: TextField(
                    controller: startDateController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.translate('start_date'),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectDate(context, endDateController),
                child: AbsorbPointer(
                  child: TextField(
                    controller: endDateController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.translate('end_date'),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectDate(context, dueDateController),
                child: AbsorbPointer(
                  child: TextField(
                    controller: dueDateController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.translate('due_date'),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final task = model.Task(
                id: '',
                title: titleController.text.isEmpty ? '-' : titleController.text,
                description: descriptionController.text.isEmpty ? '-' : descriptionController.text,
                status: statusController.text.isEmpty ? '-' : statusController.text,
                startDate: startDateController.text.isEmpty ? '-' : startDateController.text,
                endDate: endDateController.text.isEmpty ? '-' : endDateController.text,
                dueDate: dueDateController.text.isEmpty ? '-' : dueDateController.text,
              );

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .collection('tasks')
                  .add(task.toMap());

              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.translate('add')),
          ),
        ],
      ),
    );
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