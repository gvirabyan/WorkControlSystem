import 'package:flutter/material.dart';

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
}
