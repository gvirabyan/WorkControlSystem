import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VacationScheduleTable extends StatelessWidget {
  final String companyPromoCode; // Company promo code

  const VacationScheduleTable({
    super.key,
    required this.companyPromoCode, // Passed into the constructor
  });

  // Helper function to format Timestamp to 'yyyy-MM-dd'
  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('yyyy-MM-dd').format(date.toDate());
    }
    return '-';
  }

  // Calculate duration in days, handling Timestamp inputs
  String _calculateDuration(dynamic startDate, dynamic endDate) {
    DateTime? start;
    DateTime? end;

    if (startDate is Timestamp) {
      start = startDate.toDate();
    }
    if (endDate is Timestamp) {
      end = endDate.toDate();
    }

    if (start == null || end == null) {
      return '-';
    }

    // Duration includes both start and end dates (+1)
    final days = end.difference(start).inDays + 1;
    return '$days day${days != 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // NOTE: This uses a Collection Group Query. A Firestore index on
      // the 'employeeVacation' collection group, filtered by 'promoCode'
      // and ordered by 'startDate', MUST be created for this to function.
      // Additionally, each document in 'employeeVacation' MUST contain
      // 'name', 'promoCode', 'startDate', and 'endDate'.
      stream: FirebaseFirestore.instance
          .collectionGroup('employeeVacation') // Querying all subcollections named 'employeeVacation'
          .where('promoCode', isEqualTo: companyPromoCode) // Filter by company code
          .orderBy('startDate', descending: false)
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columnWidths: const {
                      0: FlexColumnWidth(2), // Name
                      1: FlexColumnWidth(2), // Start Date
                      2: FlexColumnWidth(2), // End Date
                      3: FlexColumnWidth(1.5), // Duration
                      4: FlexColumnWidth(3), // Reason
                    },
                    children: [
                      _buildHeaderRow(),
                      ...docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        // Reading Timestamp objects from the standard fields
                        final startDate = data['startDate'];
                        final endDate = data['endDate'];

                        // Formatting dates for display
                        final formattedStartDate = _formatDate(startDate);
                        final formattedEndDate = _formatDate(endDate);

                        final duration = _calculateDuration(startDate, endDate);

                        return _buildDataRow(
                          name: data['name'] ?? 'N/A', // Employee name must be stored here
                          start: formattedStartDate,
                          end: formattedEndDate,
                          duration: duration,
                          reason: data['reason'] ?? '-', // Standard reason field
                          small: isSmallScreen,
                        );
                      }),
                    ],
                  ),
                ),
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
        Padding(padding: EdgeInsets.all(6), child: Text('Duration', style: style)), // Added duration header
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
        _cell(duration, style), // Added duration cell
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
