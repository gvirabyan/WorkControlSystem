import 'package:cloud_firestore/cloud_firestore.dart';

class Document {
  final String id;
  final String title;
  final String type;
  final String message;
  final List<String> files;
  final String senderId;
  final List<String> recipientIds;
  final DateTime date;

  Document({
    required this.id,
    required this.title,
    required this.type,
    required this.message,
    required this.files,
    required this.senderId,
    required this.recipientIds,
    required this.date,
  });

  factory Document.fromMap(String id, Map<String, dynamic> data) {
    return Document(
      id: id,
      title: data['title'],
      type: data['type'],
      message: data['message'],
      files: List<String>.from(data['files']),
      senderId: data['senderId'],
      recipientIds: List<String>.from(data['recipientIds']),
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'message': message,
      'files': files,
      'senderId': senderId,
      'recipientIds': recipientIds,
      'date': Timestamp.fromDate(date),
    };
  }
}
