import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pot/models/UserModel.dart';
import 'package:pot/models/document_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<UserModel>> getEmployees() async {
    final snapshot = await _db
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Document>> getDocuments(String senderId) {
    return _db
        .collection('documents')
       // .where('senderId', isEqualTo: senderId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Document.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<Document>> getReceivedDocuments(String employeeId) {
    return _db
        .collection('documents')
        .where('recipientIds', arrayContains: employeeId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Document.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> sendDocument(Document document) {
    return _db.collection('documents').add(document.toMap());
  }
}
