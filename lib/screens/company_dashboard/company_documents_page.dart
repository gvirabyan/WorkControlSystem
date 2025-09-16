import 'package:flutter/material.dart';
import 'package:pot/models/document_model.dart';
import 'package:pot/screens/company_dashboard/document_filter_dialog.dart';
import 'package:pot/screens/company_dashboard/send_document_page.dart';
import 'package:pot/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyDocumentsPage extends StatefulWidget {
  const CompanyDocumentsPage({super.key});

  @override
  State<CompanyDocumentsPage> createState() => _CompanyDocumentsPageState();
}

class _CompanyDocumentsPageState extends State<CompanyDocumentsPage> {
  final FirestoreService _firestoreService = FirestoreService();
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
  String? _companyId;

  @override
  void initState() {
    super.initState();
    _loadCompanyId();
  }

  void _loadCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _companyId = prefs.getString('userId');
    });
  }

  Future<void> _addDocument(Document document) async {
    await _firestoreService.sendDocument(document);
  }

  void _applyFilter(
      DateTime? startDate, DateTime? endDate, Map<String, bool> documentTypes) {
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
      _documentTypes = documentTypes;
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
                      onPressed: _companyId == null
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SendDocumentPage(
                                    onSend: _addDocument,
                                    companyId: _companyId!,
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
            child: _companyId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<Document>>(
                    stream: _firestoreService.getDocuments(_companyId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No documents found.'));
                      }
                      final documents = snapshot.data!;
                      final filteredDocs = documents.where((doc) {
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
                        if (selectedTypes.isNotEmpty &&
                            !selectedTypes.contains(doc.type)) {
                          return false;
                        }
                        return true;
                      }).toList();
                      return ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final document = filteredDocs[index];
                          return ListTile(
                            title: Text(document.title),
                            subtitle: Text(document.type),
                            trailing: Text(document.date
                                .toLocal()
                                .toString()
                                .split(' ')[0]),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
