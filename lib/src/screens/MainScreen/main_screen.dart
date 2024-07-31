import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:surgery_recovery_tracker/src/screens/doctor/home_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/hospital/dashboard_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/patient/patient_dashboard.dart';
import 'package:surgery_recovery_tracker/src/screens/auth/login_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  void _checkUserStatus() async {
    _user = _auth.currentUser;
    if (_user != null) {
      // Fetch user role from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _userRole = userDoc['role'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return LoginScreen();
    }

    if (_userRole == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    switch (_userRole) {
      case 'admin':
        return AdminDashboard();
      case 'doctor':
        return DoctorDashboard();
      case 'patient':
        return PatientDashboard(uid: _user!.uid);
      default:
        return Scaffold(
          body: Center(
            child: Text('Unknown role. Please contact support.'),
          ),
        );
    }
  }
}
