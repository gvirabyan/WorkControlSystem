import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AvatarUploader extends StatefulWidget {
  final String userId; // UID пользователя
  const AvatarUploader({super.key, required this.userId});

  @override
  State<AvatarUploader> createState() => _AvatarUploaderState();
}

class _AvatarUploaderState extends State<AvatarUploader> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  Future<void> _pickAndUploadAvatar() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _isLoading = true;
    });

    try {
      // Генерируем уникальное имя файла
      final fileId = const Uuid().v4();
      final fileExt = pickedFile.path.split('.').last;
      final fileName = '$fileId.$fileExt';

      // 1️⃣ Загружаем в Supabase Storage (bucket 'avatars')
      final response = await supabase.storage
          .from('avatars')
          .upload(fileName, _image!);

      if (response.error != null) {
        throw Exception(response.error!.message);
      }

      // 2️⃣ Получаем публичный URL
      final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName).data;

      // 3️⃣ Сохраняем URL в таблице 'users'
      await supabase.from('users').update({'avatar_url': publicUrl}).eq('id', widget.userId);

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
