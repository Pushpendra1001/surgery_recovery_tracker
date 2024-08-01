import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surgery_recovery_tracker/src/models/doctor.dart';
import 'package:surgery_recovery_tracker/src/models/patient.dart';
import 'package:surgery_recovery_tracker/src/models/user.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  
  Future<void> setUserData(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  
  Future<void> addPatient(PatientModel patient) async {
    await _db.collection('patients').doc(patient.uid).set(patient.toMap());
  }

  
  Stream<List<PatientModel>> getPatients() {
    return _db.collection('patients').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PatientModel.fromMap(doc.data())).toList();
    });
  }

  Future<void> addDoctor(Map<String, dynamic> doctorData) async {
    await _db.collection('doctors').doc(doctorData['uid']).set(doctorData);
  }

  
  Future<Doctor> getDoctor(String uid) async {
    DocumentSnapshot doc = await _db.collection('doctors').doc(uid).get();
    return Doctor.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  
  Future<UserModel?> getUserByUid(String uid) async {
    DocumentSnapshot snapshot = await _db.collection('users').doc(uid).get();
    if (snapshot.exists) {
      return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
    }
    return null;
  }
}
