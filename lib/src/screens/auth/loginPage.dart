import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:surgery_recovery_tracker/src/screens/doctor/home_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/hospital/dashboard_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/patient/patient_dashboard.dart';
import 'package:surgery_recovery_tracker/src/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _userRole;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

 @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  void _checkUserStatus() async {
    _user = FirebaseAuth.instance.currentUser;
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

  void _login() async {
    if (_formKey.currentState!.validate()) {
      User? user = await _auth.signInWithEmailAndPassword(emailController.text, passwordController.text);
      if (user != null) {
        String? role = _userRole;
        
          switch (role) {
            case 'patient':
              print(role);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PatientDashboard()));
              break;
            case 'doctor':
              print(role);

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DoctorDashboard()));
              break;
            case 'admin':
              print(role);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
              break;
            default:
              print("No role");
              break;
          }
       
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Welcome User',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 32),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) => value!.isEmpty ? 'Enter a password' : null,
                    ),
                    SizedBox(height: 32),
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.7,
                        child: ElevatedButton(
                          onPressed: _login,
                          child: Text(
                            'Log In',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffA020F0),
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
