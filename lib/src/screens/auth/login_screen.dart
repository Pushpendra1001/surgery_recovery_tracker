// import 'package:surgery_recovery_tracker/src/screens/doctor/home_screen.dart';
// import 'package:surgery_recovery_tracker/src/screens/hospital/dashboard_screen.dart';
// import 'package:surgery_recovery_tracker/src/screens/patient/patient_dashboard.dart';
// import 'package:surgery_recovery_tracker/src/services/auth_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final AuthService _authService = AuthService();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   User? _user;
//   String? _userRole;

//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _checkUserStatus() async {
//     _user = _authService.currentUser;
//     if (_user != null) {
//       // Fetch user role from Firestore
//       DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();
//       if (userDoc.exists) {
//         setState(() {
//           _userRole = userDoc['role'];
//         });
//         _navigateBasedOnRole();
//       }
//     }
//   }

//   void _navigateBasedOnRole() {
//     if (_userRole == 'admin') {
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
//     } else if (_userRole == 'patient') {
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PatientDashboard()));
//     } else if (_userRole == 'doctor') {
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DoctorDashboard()));
     
//     } else {
//       // Handle other roles or show an error
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Unknown role: $_userRole')),
//       );
//     }
//   }

//   void _login() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         UserCredential userCredential = await _authService.signInWithEmailAndPassword(
//           emailController.text.trim(),
//           passwordController.text.trim(),
//         );
//         _user = userCredential.user;
//         await _checkUserStatus();
//       } catch (e) {
//         // Handle login error
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Login failed: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             // Your form fields here
//             TextFormField(
//               controller: emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your email';
//                 }
//                 return null;
//               },
//             ),
//             TextFormField(
//               controller: passwordController,
//               decoration: InputDecoration(labelText: 'Password'),
//               obscureText: true,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your password';
//                 }
//                 return null;
//               },
//             ),
//             ElevatedButton(
//               onPressed: _login,
//               child: Text('Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }