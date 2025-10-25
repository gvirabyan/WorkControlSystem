import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pot/l10n/app_localizations.dart';
import 'package:pot/models/UserModel.dart';
import 'package:pot/models/document_model.dart';
import 'package:pot/services/firestore_service.dart';
import 'package:pot/ui_elements/app_dropdown_form_field.dart';
import 'package:pot/ui_elements/app_input_field.dart';

class SendDocumentPage extends StatefulWidget {
  final Function(Document) onSend;
  final String companyId;
  const SendDocumentPage(
      {super.key, required this.onSend, required this.companyId});

  @override
  State<SendDocumentPage> createState() => _SendDocumentPageState();
}

class _SendDocumentPageState extends State<SendDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedDocumentType;
  final List<String> _documentTypes = [
    'Request',
    'Complaint',
    'Vacation',
    'Meeting',
    'Report',
    'Other',
  ];
  List<UserModel> _employees = [];
  List<UserModel> _selectedEmployees = [];
  List<File> _selectedFiles = [];
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoadingEmployees = false;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<String?> _getCompanyPromoCode() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.companyId)
        .get();
    if (doc.exists) {
      return doc.data()?['promoCode'] as String?;
    }
    return null;
  }

  void _loadEmployees() async {
    setState(() {
      _isLoadingEmployees = true;
    });

    // 🔹 Получаем promoCode компании
    final promoCode = await _getCompanyPromoCode();

    if (promoCode != null) {
      // 🔹 Загружаем сотрудников с promoCode и type == 'employee'
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('promoCode', isEqualTo: promoCode)
          .where('type', isEqualTo: 'employee')
          .get();

      _employees = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.id, doc.data()))
          .toList();
    } else {
      _employees = [];
    }

    setState(() {
      _isLoadingEmployees = false;
    });
  }

  void _showEmployeeSelectionDialog() async {
    final List<UserModel>? result = await showDialog<List<UserModel>>(
      context: context,
      builder: (context) {
        final tempSelectedEmployees = List<UserModel>.from(_selectedEmployees);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                  AppLocalizations.of(context)!.translate('select_employees')),
              content: SizedBox(
                width: double.maxFinite,
                child: _isLoadingEmployees
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _employees.length,
                        itemBuilder: (context, index) {
                          final employee = _employees[index];
                          final isSelected = tempSelectedEmployees
                              .any((e) => e.id == employee.id);
                          return CheckboxListTile(
                            title: Text(employee.name),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value!) {
                                  tempSelectedEmployees.add(employee);
                                } else {
                                  tempSelectedEmployees
                                      .removeWhere((e) => e.id == employee.id);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child:
                      Text(AppLocalizations.of(context)!.translate('cancel')),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(tempSelectedEmployees);
                  },
                  child: Text(AppLocalizations.of(context)!.translate('done')),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedEmployees = result;
      });
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('send_document')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ElevatedButton(
                onPressed: _showEmployeeSelectionDialog,
                child: Text(
                    AppLocalizations.of(context)!.translate('select_employees')),
              ),
              Wrap(
                children: _selectedEmployees
                    .map((e) => Chip(label: Text(e.name)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              AppInputField(
                controller: _titleController,
                label: AppLocalizations.of(context)!.translate('title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .translate('please_enter_a_title');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppDropdownFormField(
                value: _selectedDocumentType,
                label: AppLocalizations.of(context)!.translate('document_type'),
                items: _documentTypes,
                onChanged: (newValue) {
                  setState(() {
                    _selectedDocumentType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context)!
                        .translate('please_select_a_document_type');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppInputField(
                controller: _messageController,
                label: AppLocalizations.of(context)!.translate('message'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .translate('please_enter_a_message');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickFiles,
                child:
                    Text(AppLocalizations.of(context)!.translate('attach_files')),
              ),
              Wrap(
                children: _selectedFiles
                    .map((e) => Chip(label: Text(e.path.split('/').last)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedFiles.isEmpty) {
                      final newDocument = Document(
                        id: '',
                        title: _titleController.text,
                        type: _selectedDocumentType!,
                        message: _messageController.text,
                        files: [],
                        senderId: widget.companyId,
                        recipientIds:
                            _selectedEmployees.map((e) => e.id).toList(),
                        date: DateTime.now(),
                      );
                      await widget.onSend(newDocument);
                    } else {
                      for (final file in _selectedFiles) {
                        final newDocument = Document(
                          id: '',
                          title: _titleController.text,
                          type: _selectedDocumentType!,
                          message: _messageController.text,
                          files: [file.path],
                          senderId: widget.companyId,
                          recipientIds:
                              _selectedEmployees.map((e) => e.id).toList(),
                          date: DateTime.now(),
                        );
                        await widget.onSend(newDocument);
                      }
                    }

                    Navigator.of(context).pop();
                  }
                },
                child: Text(AppLocalizations.of(context)!.translate('send')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
