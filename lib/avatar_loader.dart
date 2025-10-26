import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pot/l10n/app_localizations.dart';

class AvatarUploader extends StatefulWidget {
  final String userId;
  const AvatarUploader({super.key, required this.userId});

  @override
  State<AvatarUploader> createState() => _AvatarUploaderState();
}

class _AvatarUploaderState extends State<AvatarUploader> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickAndUploadAvatar() async {
    final localizations = AppLocalizations.of(context)!;
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _isLoading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('avatars/${widget.userId}.jpg');

      await storageRef.putFile(_image!);

      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'avatarUrl': downloadUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(localizations.translate('avatar_updated_successfully'))),
      );
    } catch (e) {
      print('${localizations.translate('error_uploading_avatar')}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${localizations.translate('error_uploading_avatar')}: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
              : Text(localizations.translate('upload_avatar')),
        ),
      ],
    );
  }
}
