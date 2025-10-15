import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VacationPage extends StatelessWidget {
  final String userId;

  const VacationPage({super.key, required this.userId});

  Future<void> _updateStatus(BuildContext context, String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('employeeVacation')
        .doc(docId)
        .update({'status': newStatus});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to "$newStatus"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Vacations'),
        backgroundColor: Colors.orange,
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
              final startDate = data['startDate'] ?? '-';
              final endDate = data['endDate'] ?? '-';
              final reason = data['reason'] ?? '-';
              final status = (data['status'] ?? 'unknown').toString().toLowerCase();

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
                            color: status == 'approved'
                                ? Colors.green
                                : status == 'pending'
                                ? Colors.orange
                                : status == 'vacation'
                                ? Colors.blue
                                : Colors.grey,
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'From $startDate to $endDate',
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
                            'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: status == 'approved'
                                  ? Colors.green
                                  : status == 'pending'
                                  ? Colors.orange
                                  : status == 'vacation'
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                          if (status == 'pending') ...[
                            ElevatedButton(
                              onPressed: () => _updateStatus(context, doc.id, 'approved'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('Accept'),
                            ),
                            ElevatedButton(
                              onPressed: () => _updateStatus(context, doc.id, 'declined'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Decline'),
                            ),
                          ] else if (status == 'vacation') ...[
                            ElevatedButton(
                              onPressed: () => _updateStatus(context, doc.id, 'returned'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              child: const Text('Early return to work'),
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
