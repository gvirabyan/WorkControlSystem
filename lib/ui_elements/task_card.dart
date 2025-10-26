import 'package:flutter/material.dart';
import 'package:pot/l10n/app_localizations.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(task.description),
            const SizedBox(height: 4),
            Text('${localizations.translate('status')}: ${task.status}'),
            const SizedBox(height: 4),
            Text(
                '${localizations.translate('start_date')}: ${task.startDate}'),
            Text('${localizations.translate('end_date')}: ${task.endDate}'),
            Text('${localizations.translate('due_date')}: ${task.dueDate}'),
          ],
        ),
      ),
    );
  }
}
