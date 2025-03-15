import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference facultyCollection = FirebaseFirestore.instance.collection('faculties');
  final CollectionReference organizeCollection = FirebaseFirestore.instance.collection('organizations');

  Stream<DocumentSnapshot?> getUserData(String userEmail) {
    return userCollection
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
    });
  }

  Future updateUserPhone(String docId, String phoneNumber) async {
    try {
      await userCollection.doc(docId).update({'phoneNumber': phoneNumber});
    } catch (e) {
      print('Error updating user phone number: $e');
    }
  }
  Future<DocumentSnapshot> getFacultiesById(String facultyId) {
    return facultyCollection.doc(facultyId).get();
  }

  Future<List<Map<String, String>>> getDepartments(List<String> types) async {
    try {
      QuerySnapshot snapshot = await organizeCollection
          .where('organizationType', whereIn: types)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['organizationName'].toString(),
        };
      }).toList();
    } catch (e) {
      print('Error fetching departments: $e');
      return [];
    }
  }
}