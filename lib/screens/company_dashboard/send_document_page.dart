import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pot/models/UserModel.dart';
import 'package:pot/models/document_model.dart';
import 'package:pot/services/firestore_service.dart';

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

  void _loadEmployees() async {
    setState(() {
      _isLoadingEmployees = true;
    });
    _employees = await _firestoreService.getEmployees();
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
              title: const Text('Select Employees'),
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
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(tempSelectedEmployees);
                  },
                  child: const Text('Done'),
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
        title: const Text('Send Document'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ElevatedButton(
                onPressed: _showEmployeeSelectionDialog,
                child: const Text('Select Employees'),
              ),
              Wrap(
                children: _selectedEmployees
                    .map((e) => Chip(label: Text(e.name)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDocumentType,
                decoration: const InputDecoration(
                  labelText: 'Document Type',
                  border: OutlineInputBorder(),
                ),
                items: _documentTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDocumentType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a document type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickFiles,
                child: const Text('Attach Files'),
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
                    final newDocument = Document(
                      id: '',
                      title: _titleController.text,
                      type: _selectedDocumentType!,
                      message: _messageController.text,
                      files: _selectedFiles.map((e) => e.path).toList(),
                      senderId: widget.companyId,
                      recipientIds:
                          _selectedEmployees.map((e) => e.id).toList(),
                      date: DateTime.now(),
                    );
                    await widget.onSend(newDocument);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
