import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CompanyProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Получаем профиль компании
  Future<Map<String, dynamic>?> getCompanyProfile(String companyId) async {
    try {
      final doc = await _firestore.collection('users').doc(companyId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting company profile: $e');
      return null;
    }
  }

  /// Сохраняем профиль компании
  Future<void> saveCompanyProfile({
    required String companyId,
    required String officialCompanyName,
    required String commercialName, // 🔹 новое поле
    required String registeredAddress,
    required String registrationNumber,
    required String vatNumber,
    required String socialSecurityNumber,
    required String sectorOfActivity,
    required String phone,
    required String email,
    required String website,
    required String managerFirstName,
    required String managerLastName,
    required String managerPosition,
    required String hrManagerFirstName,
    required String hrManagerLastName,
    required String technicalContact,
    String? avatarUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(companyId).set({
        'officialCompanyName': officialCompanyName,
        'commercialName': commercialName, // 🔹 сохраняем новое поле
        'registeredAddress': registeredAddress,
        'registrationNumber': registrationNumber,
        'vatNumber': vatNumber,
        'socialSecurityNumber': socialSecurityNumber,
        'sectorOfActivity': sectorOfActivity,
        'phone': phone,
        'email': email,
        'website': website,
        'managerFirstName': managerFirstName,
        'managerLastName': managerLastName,
        'managerPosition': managerPosition,
        'hrManagerFirstName': hrManagerFirstName,
        'hrManagerLastName': hrManagerLastName,
        'technicalContact': technicalContact,
        'avatarUrl': avatarUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving company profile: $e');
    }
  }

  /// Загружаем аватар в Firebase Storage
  Future<String?> uploadAvatar(String companyId, File image) async {
    try {
      final ref = _storage.ref().child('avatars').child('$companyId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }
}
