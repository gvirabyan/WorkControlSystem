import 'package:flutter/material.dart';
import 'package:pot/models/document_model.dart';
import 'package:pot/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _employeeId;

  @override
  void initState() {
    super.initState();
    _loadEmployeeId();
  }

  void _loadEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _employeeId = prefs.getString('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
      ),
      body: _employeeId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Document>>(
              stream: _firestoreService.getReceivedDocuments(_employeeId!),
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
                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    return ListTile(
                      title: Text(document.title),
                      subtitle: Text(document.type),
                      trailing: Text(
                          document.date.toLocal().toString().split(' ')[0]),
                    );
                  },
                );
              },
            ),
    );
  }
}
