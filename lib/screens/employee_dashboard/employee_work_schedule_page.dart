import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pot/l10n/app_localizations.dart';

class EmployeeWorkSchedulePage extends StatefulWidget {
  final String userId;

  const EmployeeWorkSchedulePage({super.key, required this.userId});

  @override
  State<EmployeeWorkSchedulePage> createState() =>
      _EmployeeWorkSchedulePageState();
}

class _EmployeeWorkSchedulePageState extends State<EmployeeWorkSchedulePage> {
  final Map<String, TextEditingController> startControllers = {};
  final Map<String, TextEditingController> endControllers = {};

  late List<String> daysOfWeek;

  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localizations = AppLocalizations.of(context)!;
    daysOfWeek = [
      localizations.translate('monday'),
      localizations.translate('tuesday'),
      localizations.translate('wednesday'),
      localizations.translate('thursday'),
      localizations.translate('friday'),
      localizations.translate('saturday'),
      localizations.translate('sunday'),
    ];
    for (var day in daysOfWeek) {
      startControllers[day] = TextEditingController();
      endControllers[day] = TextEditingController();
    }
    _loadSchedule();
  }

  @override
  void dispose() {
    for (var c in startControllers.values) {
      c.dispose();
    }
    for (var c in endControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSchedule() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      final data = doc.data();
      if (data != null && data['workSchedule'] != null) {
        final schedule = Map<String, dynamic>.from(data['workSchedule']);
        for (var day in daysOfWeek) {
          final entry = Map<String, dynamic>.from(schedule[day] ?? {});
          startControllers[day]?.text = entry['start'] ?? '';
          endControllers[day]?.text = entry['end'] ?? '';
        }
      }
    } catch (e) {
      debugPrint('Error loading schedule: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final formattedTime = picked.format(context);
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  Future<void> _saveSchedule() async {
    final localizations = AppLocalizations.of(context)!;
    final schedule = <String, Map<String, String>>{};
    for (var day in daysOfWeek) {
      schedule[day] = {
        'start': startControllers[day]!.text,
        'end': endControllers[day]!.text,
      };
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'workSchedule': schedule});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  localizations.translate('work_schedule_saved_successfully'))),
        );
      }
    } catch (e) {
      debugPrint('Error saving schedule: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${localizations.translate('failed_to_save')}: $e')),
        );
      }
    }
  }

  Widget _buildDayRow(String day) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              day,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: startControllers[day],
              readOnly: true,
              decoration: InputDecoration(
                labelText: localizations.translate('start'),
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onTap: () => _selectTime(context, startControllers[day]!),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: endControllers[day],
              readOnly: true,
              decoration: InputDecoration(
                labelText: localizations.translate('end'),
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onTap: () => _selectTime(context, endControllers[day]!),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('work_schedule')),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    localizations.translate('set_work_hours_for_each_day'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ...daysOfWeek.map(_buildDayRow).toList(),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _saveSchedule,
                    icon: const Icon(Icons.save),
                    label: Text(localizations.translate('save_schedule')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
