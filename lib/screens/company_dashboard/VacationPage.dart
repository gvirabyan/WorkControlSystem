import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VacationPage extends StatelessWidget {
  final String userId;

  const VacationPage({super.key, required this.userId});

  // Helper function to format Timestamp to 'dd.MM.yyyy'
  String _formatTimestamp(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('dd.MM.yyyy').format(date.toDate());
    }
    return 'N/A';
  }

  // Function to determine status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
      case 'vacation':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'declined':
      case 'prematurely_ended': // New status color
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // General function to update status and optionally update the end date
  Future<void> _updateStatus(BuildContext context, String docId, String newStatus, {DateTime? newEndDate}) async {
    final updateData = <String, dynamic>{'status': newStatus};

    if (newEndDate != null) {
      // Update the end date to the new, earlier date
      updateData['endDate'] = Timestamp.fromDate(newEndDate);
      updateData['prematurelyEnded'] = true; // Flag for clarity
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('employeeVacation')
          .doc(docId)
          .update(updateData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to "${newStatus.replaceAll('_', ' ')}"')),
        );
      }
    } catch (e) {
      // In a real app, log the error and show a user-friendly message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  // Dialog to handle setting an early return date
  Future<void> _showEarlyReturnDialog(BuildContext context, String docId, DateTime currentStartDate, DateTime currentEndDate) {
    DateTime? selectedDate = DateTime.now();
    // Ensure the initial selected date is within bounds, defaulting to the earliest possible return date (start date)
    if (selectedDate.isBefore(currentStartDate)) {
      selectedDate = currentStartDate;
    } else if (selectedDate.isAfter(currentEndDate)) {
      selectedDate = currentEndDate;
    }

    final TextEditingController dateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(selectedDate),
    );

    Future<void> pickDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        // Cannot return before the start date
        firstDate: currentStartDate,
        // Cannot return later than the original end date
        lastDate: currentEndDate,
      );
      if (picked != null) {
        selectedDate = picked;
        dateController.text = DateFormat('dd.MM.yyyy').format(picked);
        // Force update of the dialog content state if possible (though Stateless, we rely on the dialog state)
        // NOTE: This casting to Element is a workaround for StatelessWidget context rebuilds within a dialog.
        (context as Element).markNeedsBuild();
      }
    }

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('End Vacation Early'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Select the new date the employee returned to work:'),
              const SizedBox(height: 10),
              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Return Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => pickDate(),
                  ),
                ),
                onTap: () => pickDate(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirm Early End'),
              onPressed: () {
                if (selectedDate != null) {
                  Navigator.of(dialogContext).pop();
                  _updateStatus(
                    context,
                    docId,
                    'prematurely_ended', // New status for early termination
                    newEndDate: selectedDate,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Vacations'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('employeeVacation')
            .orderBy('startDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No vacation records found.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          final vacations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: vacations.length,
            itemBuilder: (context, index) {
              final doc = vacations[index];
              final data = doc.data();
              final startDateTimestamp = data['startDate'] as Timestamp?;
              final endDateTimestamp = data['endDate'] as Timestamp?;
              final reason = data['reason'] ?? 'N/A';
              final status = (data['status'] ?? 'unknown').toString().toLowerCase();

              final formattedStartDate = _formatTimestamp(startDateTimestamp);
              final formattedEndDate = _formatTimestamp(endDateTimestamp);

              final currentStartDate = startDateTimestamp?.toDate() ?? DateTime.now();
              final currentEndDate = endDateTimestamp?.toDate() ?? DateTime.now();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: _getStatusColor(status),
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              // Using formatted dates
                              'From $formattedStartDate to $formattedEndDate',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Reason: $reason'),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // Displaying status, replacing underscore with space
                            'Status: ${status.replaceAll('_', ' ')[0].toUpperCase()}${status.replaceAll('_', ' ').substring(1)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(status),
                            ),
                          ),
                          // Action Buttons
                          if (status == 'pending') ...[
                            ElevatedButton(
                              onPressed: () => _updateStatus(context, doc.id, 'approved'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              child: const Text('Accept'),
                            ),
                            ElevatedButton(
                              onPressed: () => _updateStatus(context, doc.id, 'declined'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                              child: const Text('Decline'),
                            ),
                          ] else if (status == 'vacation' || status == 'approved') ...[
                            // Button to open the dialog for early return
                            ElevatedButton.icon(
                              onPressed: () => _showEarlyReturnDialog(context, doc.id, currentStartDate, currentEndDate),
                              icon: const Icon(Icons.logout),
                              label: const Text('End Early'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
