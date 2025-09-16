import 'package:flutter/material.dart';
import 'package:pot/models/document_model.dart';
import 'package:pot/screens/company_dashboard/document_filter_dialog.dart';
import 'package:pot/screens/company_dashboard/send_document_page.dart';

class CompanyDocumentsPage extends StatefulWidget {
  const CompanyDocumentsPage({super.key});

  @override
  State<CompanyDocumentsPage> createState() => _CompanyDocumentsPageState();
}

class _CompanyDocumentsPageState extends State<CompanyDocumentsPage> {
  final List<Document> _documents = [
    Document(
      id: '1',
      title: 'Report Q1',
      type: 'Report',
      message: 'Here is the report for Q1.',
      files: [],
      senderId: 'company1',
      recipientIds: ['employee1'],
      date: DateTime(2023, 1, 15),
    ),
    Document(
      id: '2',
      title: 'Vacation Request',
      type: 'Vacation',
      message: 'I would like to request a vacation from...',
      files: [],
      senderId: 'employee2',
      recipientIds: ['company1'],
      date: DateTime(2023, 2, 20),
    ),
    Document(
      id: '3',
      title: 'Meeting Notes',
      type: 'Meeting',
      message: 'Notes from the meeting on...',
      files: [],
      senderId: 'company1',
      recipientIds: ['employee1', '-'],
      date: DateTime(2023, 3, 10),
    ),
  ];
  List<Document> _filteredDocuments = [];
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, bool> _documentTypes = {
    'Request': false,
    'Complaint': false,
    'Vacation': false,
    'Meeting': false,
    'Report': false,
    'Other': false,
    'Sent': false,
  };

  @override
  void initState() {
    super.initState();
    _filteredDocuments = _documents;
  }

  void _addDocument(Document document) {
    setState(() {
      _documents.add(document);
      _applyFilter(_startDate, _endDate, _documentTypes);
    });
  }

  void _applyFilter(
      DateTime? startDate, DateTime? endDate, Map<String, bool> documentTypes) {
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
      _documentTypes = documentTypes;
      _filteredDocuments = _documents.where((doc) {
        final docDate = doc.date;
        if (_startDate != null && docDate.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null && docDate.isAfter(_endDate!)) {
          return false;
        }
        final selectedTypes = _documentTypes.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();
        if (selectedTypes.isNotEmpty && !selectedTypes.contains(doc.type)) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Documents',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SendDocumentPage(
                              onSend: _addDocument,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => DocumentFilterDialog(
                            onApplyFilter: _applyFilter,
                            initialStartDate: _startDate,
                            initialEndDate: _endDate,
                            initialDocumentTypes: _documentTypes,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredDocuments.length,
              itemBuilder: (context, index) {
                final document = _filteredDocuments[index];
                return ListTile(
                  title: Text(document.title),
                  subtitle: Text(document.type),
                  trailing:
                      Text(document.date.toLocal().toString().split(' ')[0]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
