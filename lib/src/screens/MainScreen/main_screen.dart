import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:surgery_recovery_tracker/src/models/user.dart';
import 'package:surgery_recovery_tracker/src/screens/doctor/home_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/patient/home_screen.dart';
import 'package:surgery_recovery_tracker/src/services/firestore_service.dart';


class MainScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirestoreService().getUserData(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text('User not found');
        } else {
          UserModel userModel = UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
          if (userModel.role == 'patient') {
            return PatientDashboard();
          } else {
            return DoctorDashboard();
          }
        }
      },
    );
  }
}
