import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompanyNotesPage extends StatefulWidget {
  final String companyPromoCode;
  const CompanyNotesPage({super.key, required this.companyPromoCode});

  @override
  State<CompanyNotesPage> createState() => _CompanyNotesPageState();
}

class _CompanyNotesPageState extends State<CompanyNotesPage> {
  final _notesColl = FirebaseFirestore.instance.collection('company_notes');

  String _formatDate(Timestamp? t) {
    if (t == null) return '-';
    return DateFormat('yyyy-MM-dd HH:mm').format(t.toDate());
  }

  Future<void> _openNoteDialog({DocumentSnapshot? note}) async {
    await showDialog(
      context: context,
      builder: (_) => NoteDialog(note: note, companyPromoCode: widget.companyPromoCode),
    );
  }

  Future<void> _confirmAndDelete(DocumentSnapshot note) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok == true) {
      try {
        await _notesColl.doc(note.id).delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
        }
      }
    }
  }

  Future<String> _employeeNamesForNote(List<dynamic>? ids) async {
    if (ids == null || ids.isEmpty) return '-';
    try {
      final idStrings = ids.map((e) => e.toString()).toList();
      if (idStrings.isEmpty) return '-';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openNoteDialog(),
            tooltip: 'Create note',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notesColl
            .where('promoCode', isEqualTo: widget.companyPromoCode)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading notes: ${snapshot.error}'));
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
                        const SizedBox(height: 6),
                        Text('Recipients: $employeesLine', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('Created: $created', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    isThreeLine: text.isNotEmpty,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openNoteDialog(note: noteDoc);
                        } else if (value == 'delete') {
                          _confirmAndDelete(noteDoc);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
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

class NoteDialog extends StatefulWidget {
  final DocumentSnapshot? note;
  final String companyPromoCode;
  const NoteDialog({super.key, this.note, required this.companyPromoCode});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late final TextEditingController titleController;
  late final TextEditingController textController;
  final Set<String> selectedEmployeeIds = {};
  bool selectAll = false;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?['title'] ?? '');
    textController = TextEditingController(text: widget.note?['text'] ?? '');
    final initialEmployees = List<String>.from(widget.note?['employees'] ?? []);
    selectedEmployeeIds.addAll(initialEmployees);
    selectAll = false;
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = titleController.text.trim();
    final text = textController.text.trim();
    if (title.isEmpty && text.isEmpty && selectedEmployeeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter title, text or select at least one employee')),
      );
      return;
    }

    setState(() => submitting = true);
    final now = FieldValue.serverTimestamp();
    final payload = <String, dynamic>{
      'title': title,
      'text': text,
      'employees': selectedEmployeeIds.toList(),
      'promoCode': widget.companyPromoCode,
      'updatedAt': now,
    };

    try {
      final notesColl = FirebaseFirestore.instance.collection('company_notes');
      if (widget.note == null) {
        payload['createdAt'] = now;
        await notesColl.add(payload);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note created')));
        }
      } else {
        await notesColl.doc(widget.note!.id).update(payload);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note updated')));
        }
      }
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save note: $e')));
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'employee')
          .where('promoCode', isEqualTo: widget.companyPromoCode)
          .get(),
      builder: (context, snapshot) {
        final employees = snapshot.data?.docs ?? [];

        return AlertDialog(
          title: Text(widget.note == null ? 'Create Note' : 'Edit Note'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 10),
                  TextField(controller: textController, maxLines: 3, decoration: const InputDecoration(labelText: 'Note text')),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Select employees:'),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectAll = !selectAll;
                            selectedEmployeeIds.clear();
                            if (selectAll) {
                              selectedEmployeeIds.addAll(employees.map((e) => e.id));
                            }
                          });
                        },
                        child: Text(selectAll ? 'Unselect All' : 'Select All'),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (employees.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('No employees available'),
                    ),
                  ...employees.map((e) {
                    final name = (e['name'] ?? '${e['firstName'] ?? ''} ${e['lastName'] ?? ''}').toString().trim();
                    final id = e.id;
                    final checked = selectedEmployeeIds.contains(id);
                    return CheckboxListTile(
                      title: Text(name.isEmpty ? 'Unnamed' : name),
                      value: checked,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedEmployeeIds.add(id);
                          } else {
                            selectedEmployeeIds.remove(id);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: submitting ? null : _saveNote, child: Text(widget.note == null ? 'Create' : 'Save')),
          ],
        );
      },
    );
  }
}
