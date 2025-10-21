import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VacationScheduleTable extends StatefulWidget {
  final String companyPromoCode;
  const VacationScheduleTable({super.key, required this.companyPromoCode});

  @override
  State<VacationScheduleTable> createState() => _VacationScheduleTableState();
}

class _VacationScheduleTableState extends State<VacationScheduleTable> {
  String nameFilter = '';
  DateTime? startDateFilter;
  DateTime? endDateFilter;

  String _formatDate(dynamic date) {
    if (date is Timestamp) return DateFormat('yyyy-MM-dd').format(date.toDate());
    return '-';
  }

  String _calculateDuration(dynamic startDate, dynamic endDate) {
    DateTime? start;
    DateTime? end;

    if (startDate is Timestamp) start = startDate.toDate();
    if (endDate is Timestamp) end = endDate.toDate();
    if (start == null || end == null) return '-';

    final days = end.difference(start).inDays + 1;
    return '$days day${days != 1 ? 's' : ''}';
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDateFilter ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => startDateFilter = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDateFilter ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => endDateFilter = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- все фильтры в один ряд ---
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (v) => setState(() => nameFilter = v.trim().toLowerCase()),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _pickStartDate,
                child: Text(startDateFilter == null
                    ? 'Start Date'
                    : DateFormat('yyyy-MM-dd').format(startDateFilter!)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _pickEndDate,
                child: Text(endDateFilter == null
                    ? 'End Date'
                    : DateFormat('yyyy-MM-dd').format(endDateFilter!)),
              ),
            ],
          ),
        ),

        // --- таблица с данными ---
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('vacations')
                .where('promoCode', isEqualTo: widget.companyPromoCode)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No vacation records found', style: TextStyle(fontSize: 16)));
              }

              final docs = snapshot.data!.docs;

              // --- собираем userIds для имен
              final userIds = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['userId'] as String?;
              }).whereType<String>().toSet();

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where(FieldPath.documentId, whereIn: userIds.isEmpty ? [''] : userIds.toList())
                    .get(),
                builder: (context, usersSnapshot) {
                  if (usersSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final userMap = <String, String>{};
                  if (usersSnapshot.hasData) {
                    for (var userDoc in usersSnapshot.data!.docs) {
                      final udata = userDoc.data() as Map<String, dynamic>;
                      userMap[userDoc.id] = udata['name'] ?? 'N/A';
                    }
                  }

                  // --- фильтруем локально
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = userMap[data['userId']]?.toLowerCase() ?? '';
                    final startDate = data['startDate'] is Timestamp ? (data['startDate'] as Timestamp).toDate() : null;
                    final endDate = data['endDate'] is Timestamp ? (data['endDate'] as Timestamp).toDate() : null;

                    bool matches = true;
                    if (nameFilter.isNotEmpty) matches &= name.contains(nameFilter);
                    if (startDateFilter != null && startDate != null) matches &= startDate.isAtSameMomentAs(startDateFilter!) || startDate.isAfter(startDateFilter!);
                    if (endDateFilter != null && endDate != null) matches &= endDate.isAtSameMomentAs(endDateFilter!) || endDate.isBefore(endDateFilter!);

                    return matches;
                  }).toList();

                  if (filteredDocs.isEmpty) return const Center(child: Text('No vacation records match filters'));

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallScreen = constraints.maxWidth < 600;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: Table(
                            border: TableBorder.all(color: Colors.grey.shade300),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(1.5),
                              4: FlexColumnWidth(3),
                            },
                            children: [
                              _buildHeaderRow(),
                              ...filteredDocs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final start = _formatDate(data['startDate']);
                                final end = _formatDate(data['endDate']);
                                final duration = _calculateDuration(data['startDate'], data['endDate']);
                                final reason = data['reason'] ?? '-';
                                final name = userMap[data['userId']] ?? 'N/A';
                                return _buildDataRow(
                                    name: name,
                                    start: start,
                                    end: end,
                                    duration: duration,
                                    reason: reason,
                                    small: isSmallScreen);
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  TableRow _buildHeaderRow() {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFEDEDED)),
      children: [
        Padding(padding: EdgeInsets.all(6), child: Text('Name', style: style)),
        Padding(padding: EdgeInsets.all(6), child: Text('Start Date', style: style)),
        Padding(padding: EdgeInsets.all(6), child: Text('End Date', style: style)),
        Padding(padding: EdgeInsets.all(6), child: Text('Duration', style: style)),
        Padding(padding: EdgeInsets.all(6), child: Text('Reason', style: style)),
      ],
    );
  }

  TableRow _buildDataRow({
    required String name,
    required String start,
    required String end,
    required String reason,
    required String duration,
    required bool small,
  }) {
    final style = TextStyle(fontSize: small ? 11 : 13);
    return TableRow(
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05)),
      children: [
        _cell(name, style),
        _cell(start, style),
        _cell(end, style),
        _cell(duration, style),
        _cell(reason, style),
      ],
    );
  }

  Widget _cell(String text, TextStyle style) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
    child: Text(
      text,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: style,
    ),
  );
}
