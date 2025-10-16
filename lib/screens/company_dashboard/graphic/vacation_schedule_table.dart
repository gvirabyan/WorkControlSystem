import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VacationScheduleTable extends StatelessWidget {
  final String companyPromoCode; // добавляем promoCode компании

  const VacationScheduleTable({
    super.key,
    required this.companyPromoCode, // передаём в конструктор
  });

  String _calculateDuration(String? startDate, String? endDate) {
    if (startDate == null || endDate == null || startDate.isEmpty || endDate.isEmpty) {
      return '-';
    }
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      final days = end.difference(start).inDays + 1;
      return '$days day${days > 1 ? 's' : ''}';
    } catch (_) {
      return '-';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vacations')
          .where('promoCode', isEqualTo: companyPromoCode) // фильтруем по компании
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No vacation records found',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FlexColumnWidth(2), // Name
                  1: FlexColumnWidth(2), // Start Date
                  2: FlexColumnWidth(2), // End Date
                  3: FlexColumnWidth(3), // Reason
                },
                children: [
                  _buildHeaderRow(),
                  ...docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final startDate = _formatDate(data['vacationStartDate']?.toString());
                    final endDate = _formatDate(data['vacationEndDate']?.toString());
                    final duration = _calculateDuration(
                      data['vacationStartDate']?.toString(),
                      data['vacationEndDate']?.toString(),
                    );

                    return _buildDataRow(
                      name: data['name'] ?? '',
                      start: startDate,
                      end: endDate,
                      reason: data['vacationReason'] ?? '-',
                      duration: duration,
                      small: isSmallScreen,
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
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
