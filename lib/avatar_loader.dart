import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AvatarUploader extends StatefulWidget {
  final String userId; // например, UID пользователя
  const AvatarUploader({super.key, required this.userId});

  @override
  State<AvatarUploader> createState() => _AvatarUploaderState();
}

class _AvatarUploaderState extends State<AvatarUploader> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickAndUploadAvatar() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _isLoading = true;
    });

    try {
      // 1️⃣ Загружаем в Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('avatars/${widget.userId}.jpg');

      await storageRef.putFile(_image!);

      // 2️⃣ Получаем публичный URL
      final downloadUrl = await storageRef.getDownloadURL();

      // 3️⃣ Сохраняем URL в Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'avatarUrl': downloadUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Аватар успешно обновлён ✅')),
      );
    } catch (e) {
      print('Ошибка загрузки: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _image != null
            ? CircleAvatar(
          radius: 50,
          backgroundImage: FileImage(_image!),
        )
            : const CircleAvatar(
          radius: 50,
          child: Icon(Icons.person, size: 40),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _pickAndUploadAvatar,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Загрузить аватар'),
        ),
      ],
    );
  }
}
