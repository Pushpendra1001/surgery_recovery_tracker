import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:surgery_recovery_tracker/firebase_options.dart';
import 'package:surgery_recovery_tracker/src/screens/MainScreen/main_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/auth/loginPage.dart';
import 'package:surgery_recovery_tracker/src/screens/auth/login_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/auth/register_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/hospital/dashboard_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/patient/patient_dashboard.dart';
import 'package:surgery_recovery_tracker/src/services/auth_service.dart';
import 'package:surgery_recovery_tracker/src/services/firestore_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // await createAdmin();
  return runApp(const MyApp());
}

Future<void> createAdmin() async {
  final AuthService _auth = AuthService();
  final FirestoreService _db = FirestoreService();
  String email = 'admin@gmail.com'; // replace with desired email
  String password = 'admin123';  // replace with desired password
  String name = 'Admin';         // replace with desired name

  User? user = await _auth.registerWithEmailAndPassword(email, password);
  if (user != null) {
    await _db.setUserData(user.uid, {
      'uid': user.uid,
      'email': email,
      'name': name,
      'role': 'admin',
    });
    print('Admin account created successfully');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  PatientDashboard(),
    );
  }
}

