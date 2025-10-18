import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'vacation_request_form.dart'; // Assuming this file exists

class RequestVacationPage extends StatelessWidget {
  final String userId;

  const RequestVacationPage({super.key, required this.userId});

  // Helper function for date formatting
  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('dd.MM.yyyy').format(date.toDate());
    }
    return date.toString();
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
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vacation Requests'), // Translated
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('employeeVacation')
        // Sorting to check the latest status
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}')); // Translated
          }

          final vacations = snapshot.data!.docs;

          // Check if there is an active or pending request
          final hasActiveOrPending = vacations.any(
                (doc) {
              final status = (doc.data()['status'] ?? 'unknown').toString().toLowerCase();
              return status == 'pending' || status == 'approved' || status == 'vacation';
            },
          );

          return Column(
            children: [
              // Vacation creation button (shown only if no active request exists)
              if (!hasActiveOrPending)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VacationRequestForm(userId: userId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_box),
                    label: const Text('Create Vacation Request', style: TextStyle(fontSize: 16)), // Translated
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'You already have an active or pending vacation request.', // Translated
                    style: TextStyle(fontSize: 15, color: Colors.blueGrey),
                    textAlign: TextAlign.center,
                  ),
                ),

              const Divider(height: 1, thickness: 1),

              // List of requests
              Expanded(
                child: vacations.isEmpty
                    ? const Center(child: Text('No vacation requests found.')) // Translated
                    : ListView.builder(
                  itemCount: vacations.length,
                  itemBuilder: (context, index) {
                    final doc = vacations[index];
                    final data = doc.data();
                    final startDate = data['startDate'];
                    final endDate = data['endDate'];
                    final reason = data['reason'] ?? 'Reason not specified'; // Translated
                    final status = (data['status'] ?? 'unknown').toString().toLowerCase();
                    final color = _getStatusColor(status);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      child: ListTile(
                        leading: Icon(Icons.beach_access, color: color, size: 30),
                        title: Text(
                          'From ${_formatDate(startDate)} to ${_formatDate(endDate)}', // Translated
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Reason: $reason'), // Translated
                        trailing: Chip(
                          label: Text(
                            status[0].toUpperCase() + status.substring(1),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: color,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}