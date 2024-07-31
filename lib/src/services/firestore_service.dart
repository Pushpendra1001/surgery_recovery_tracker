import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surgery_recovery_tracker/src/models/patient.dart';
import 'package:surgery_recovery_tracker/src/models/user.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Set user data
  Future<void> setUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data);
  }

  // Add patient
  Future<void> addPatient(PatientModel patient) async {
    await _db.collection('patients').doc(patient.uid).set(patient.toMap());
  }

  // Get patients
  Stream<List<PatientModel>> getPatients() {
    return _db.collection('patients').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PatientModel.fromMap(doc.data())).toList();
    });
  }

  // Get user by uid
  Future<UserModel?> getUserByUid(String uid) async {
    DocumentSnapshot snapshot = await _db.collection('users').doc(uid).get();
    if (snapshot.exists) {
      return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
    }
    return null;
  }
}
