import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final List<String> daysOfWeek = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
          const SnackBar(content: Text('Work schedule saved successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error saving schedule: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  Widget _buildDayRow(String day) {
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
              decoration: const InputDecoration(
                labelText: 'Start',
                isDense: true,
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'End',
                isDense: true,
                border: OutlineInputBorder(),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Schedule'),
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
            const Text(
              'Set work hours for each day',
              style: TextStyle(
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
              label: const Text('Save Schedule'),
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
