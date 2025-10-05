import 'package:flutter/material.dart';
import 'package:pot/models/document_model.dart';

class DocumentDetailsPage extends StatelessWidget {
  final Document document;

  const DocumentDetailsPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${document.type}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${document.date.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Message:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              document.message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Attached Files:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: document.files.length,
                itemBuilder: (context, index) {
                  final file = document.files[index];
                  return ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(file.split('/').last),
                    onTap: () {
                      // TODO: Implement file opening/downloading
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}