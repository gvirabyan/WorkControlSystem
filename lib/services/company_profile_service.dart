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
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String plan,
  }) async {
    try {
      await _firestore.collection('users').doc(companyId).set({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'address': address,
        'plan': plan,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving company profile: $e');
    }
  }
}

