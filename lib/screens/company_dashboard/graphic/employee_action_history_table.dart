import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EmployeeActionHistoryTable extends StatefulWidget {
  final String promoCode;

  const EmployeeActionHistoryTable({super.key, required this.promoCode});

  @override
  State<EmployeeActionHistoryTable> createState() => _EmployeeActionHistoryTableState();
}

class _EmployeeActionHistoryTableState extends State<EmployeeActionHistoryTable> {
  final _nameController = TextEditingController();
  DateTime? _startFilter;
  DateTime? _endFilter;

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    try {
      final date = timestamp.toDate();
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    } catch (e) {
      return '-';
    }
  }

  String _calculateDuration(Timestamp? start, Timestamp? end) {
    if (start == null || end == null) return '-';
    final duration = end.toDate().difference(start.toDate());
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  bool _matchesFilters(Map<String, dynamic> data) {
    final name = (data['name'] ?? '').toString().toLowerCase();
    if (_nameController.text.isNotEmpty &&
        !name.contains(_nameController.text.toLowerCase())) return false;

    final start = data['datetimeStart'] as Timestamp?;
    final end = data['datetimeEnd'] as Timestamp?;

    if (_startFilter != null && (start == null || start.toDate().isBefore(_startFilter!))) return false;
    if (_endFilter != null && (end == null || end.toDate().isAfter(_endFilter!))) return false;

    return true;
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startFilter = picked;
        } else {
          _endFilter = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('employee_action_history')
          .where('promoCode', isEqualTo: widget.promoCode)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No employee action records found', style: TextStyle(fontSize: 16)));
        }

        final docs = snapshot.data!.docs;

        return Column(
          children: [
            // --- Filters Row ---
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => _pickDate(context, true),
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            hintText: _startFilter != null ? DateFormat('yyyy-MM-dd').format(_startFilter!) : '',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => _pickDate(context, false),
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            hintText: _endFilter != null ? DateFormat('yyyy-MM-dd').format(_endFilter!) : '',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Table Header ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              color: Colors.grey[300],
              child: Row(
                children: const [
                  Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 2, child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 3, child: Text('Start Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(flex: 3, child: Text('End Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                ],
              ),
            ),

            // --- Table Rows ---
            ...docs.where((doc) => _matchesFilters(doc.data() as Map<String, dynamic>)).map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final start = data['datetimeStart'] as Timestamp?;
              final end = data['datetimeEnd'] as Timestamp?;
              final startStr = _formatDateTime(start);
              final endStr = _formatDateTime(end);

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: Text(data['name'] ?? '-', style: const TextStyle(fontSize: 12))),
                    Expanded(flex: 2, child: Text(data['action'] ?? '-', style: const TextStyle(fontSize: 12))),
                    Expanded(flex: 3, child: Text(startStr, style: const TextStyle(fontSize: 12))),
                    Expanded(flex: 3, child: Text(endStr, style: const TextStyle(fontSize: 12))),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
