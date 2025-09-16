import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> saveCompanyProfile({
    required String companyId,
    required String officialCompanyName,
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
  }) async {
    try {
      await _firestore.collection('users').doc(companyId).set({
        'officialCompanyName': officialCompanyName,
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
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving company profile: $e');
    }
  }
}

