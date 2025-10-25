import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pot/l10n/app_localizations.dart';

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
      builder: (_) =>
          NoteDialog(note: note, companyPromoCode: widget.companyPromoCode),
    );
  }

  Future<void> _confirmAndDelete(DocumentSnapshot note) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('delete_note')),
        content: Text(AppLocalizations.of(context)!
            .translate('are_you_sure_you_want_to_delete_this_note')),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(AppLocalizations.of(context)!.translate('cancel'))),
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(AppLocalizations.of(context)!.translate('delete'))),
        ],
      ),
    );

    if (ok == true) {
      try {
        await _notesColl.doc(note.id).delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.translate('note_deleted'))));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.translate('delete_failed')}$e')));
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
        final chunk =
            idStrings.sublist(i, (i + chunkSize).clamp(0, idStrings.length));
        final q = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (var doc in q.docs) {
          final d = doc.data() as Map<String, dynamic>? ?? {};
          final n = (d['name'] ?? '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}')
              .toString()
              .trim();
          names.add(n.isEmpty
              ? AppLocalizations.of(context)!.translate('unnamed')
              : n);
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
        title: Text(AppLocalizations.of(context)!.translate('company_notes')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openNoteDialog(),
            tooltip: AppLocalizations.of(context)!.translate('create_note'),
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
            return Center(
                child: Text(
                    '${AppLocalizations.of(context)!.translate('error_loading_notes')}${snapshot.error}'));
          }

          final notes = snapshot.data?.docs ?? [];
          if (notes.isEmpty)
            return Center(
                child: Text(
                    AppLocalizations.of(context)!.translate('no_notes_yet')));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => const Divider(),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final noteDoc = notes[index];
              final data = noteDoc.data() as Map<String, dynamic>? ?? {};
              final title = (data['title'] ??
                      AppLocalizations.of(context)!.translate('unnamed'))
                  .toString();
              final text = (data['text'] ?? '').toString();
              final created = data['createdAt'] is Timestamp
                  ? _formatDate(data['createdAt'] as Timestamp)
                  : '-';
              final employeeIds = List<dynamic>.from(data['employees'] ?? []);

              return FutureBuilder<String>(
                future: _employeeNamesForNote(employeeIds),
                builder: (ctx, namesSnap) {
                  final employeesLine =
                      namesSnap.connectionState == ConnectionState.waiting
                          ? AppLocalizations.of(context)!
                              .translate('loading_recipients')
                          : (namesSnap.data ?? '-');

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    title: Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (text.isNotEmpty) Text(text),
                        const SizedBox(height: 6),
                        Text(
                            '${AppLocalizations.of(context)!.translate('recipients')}$employeesLine',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                            '${AppLocalizations.of(context)!.translate('created')}$created',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
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
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: 'edit',
                            child: Text(
                                AppLocalizations.of(context)!.translate('edit'))),
                        PopupMenuItem(
                            value: 'delete',
                            child: Text(AppLocalizations.of(context)!
                                .translate('delete'))),
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
    final initialEmployees =
        List<String>.from(widget.note?['employees'] ?? []);
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
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('enter_title_text_or_select_employee'))),
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.translate('note_created'))));
        }
      } else {
        await notesColl.doc(widget.note!.id).update(payload);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.translate('note_updated'))));
        }
      }
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.translate('failed_to_save_note')}$e')));
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
          title: Text(widget.note == null
              ? AppLocalizations.of(context)!.translate('create_note')
              : AppLocalizations.of(context)!.translate('edit_note')),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!
                              .translate('title'))),
                  const SizedBox(height: 10),
                  TextField(
                      controller: textController,
                      maxLines: 3,
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!
                              .translate('note_text'))),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!
                          .translate('select_employees_colon')),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectAll = !selectAll;
                            selectedEmployeeIds.clear();
                            if (selectAll) {
                              selectedEmployeeIds
                                  .addAll(employees.map((e) => e.id));
                            }
                          });
                        },
                        child: Text(selectAll
                            ? AppLocalizations.of(context)!
                                .translate('unselect_all')
                            : AppLocalizations.of(context)!
                                .translate('select_all')),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (employees.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(AppLocalizations.of(context)!
                          .translate('no_employees_available')),
                    ),
                  ...employees.map((e) {
                    final name = (e['name'] ??
                            '${e['firstName'] ?? ''} ${e['lastName'] ?? ''}')
                        .toString()
                        .trim();
                    final id = e.id;
                    final checked = selectedEmployeeIds.contains(id);
                    return CheckboxListTile(
                      title: Text(name.isEmpty
                          ? AppLocalizations.of(context)!.translate('unnamed')
                          : name),
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
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.translate('cancel'))),
            ElevatedButton(
                onPressed: submitting ? null : _saveNote,
                child: Text(widget.note == null
                    ? AppLocalizations.of(context)!.translate('create')
                    : AppLocalizations.of(context)!.translate('save'))),
          ],
        );
      },
    );
  }
}
