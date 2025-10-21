import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeeNotesPage extends StatelessWidget {
  final String companyPromoCode;
  const EmployeeNotesPage({super.key, required this.companyPromoCode});

  String _formatDate(Timestamp? t) {
    if (t == null) return '-';
    return DateFormat('yyyy-MM-dd HH:mm').format(t.toDate());
  }

  Future<String> _employeeNamesForNote(List<dynamic>? ids) async {
    if (ids == null || ids.isEmpty) return '-';
    try {
      final idStrings = ids.map((e) => e.toString()).toList();
      final List<String> names = [];
      const chunkSize = 10;
      for (var i = 0; i < idStrings.length; i += chunkSize) {
        final chunk = idStrings.sublist(i, (i + chunkSize).clamp(0, idStrings.length));
        final q = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (var doc in q.docs) {
          final d = doc.data() as Map<String, dynamic>? ?? {};
          final n = (d['name'] ?? '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}').toString().trim();
          names.add(n.isEmpty ? 'Unnamed' : n);
        }
      }
      return names.join(', ');
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesColl = FirebaseFirestore.instance.collection('company_notes');

    return Scaffold(
      appBar: AppBar(title: const Text('Company Notes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: notesColl
            .where('promoCode', isEqualTo: companyPromoCode)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data?.docs ?? [];
          if (notes.isEmpty) return const Center(child: Text('No notes yet.'));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => const Divider(),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final noteDoc = notes[index];
              final data = noteDoc.data() as Map<String, dynamic>? ?? {};
              final title = (data['title'] ?? 'Untitled').toString();
              final text = (data['text'] ?? '').toString();
              final created = data['createdAt'] is Timestamp ? _formatDate(data['createdAt'] as Timestamp) : '-';
              final employeeIds = List<dynamic>.from(data['employees'] ?? []);

              return FutureBuilder<String>(
                future: _employeeNamesForNote(employeeIds),
                builder: (ctx, namesSnap) {
                  final employeesLine = namesSnap.connectionState == ConnectionState.waiting
                      ? 'Loading recipients...'
                      : (namesSnap.data ?? '-');

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (text.isNotEmpty) Text(text),
                        const SizedBox(height: 4),
                        Text('Created: $created',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
