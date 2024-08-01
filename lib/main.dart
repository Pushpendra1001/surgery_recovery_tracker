import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:surgery_recovery_tracker/firebase_options.dart';
import 'package:surgery_recovery_tracker/src/screens/auth/loginPage.dart';
import 'package:surgery_recovery_tracker/src/screens/doctor/home_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/hospital/dashboard_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/patient/patient_dashboard.dart';

Future<void> createAdminAccount() async {
  String adminEmail = 'admin1@gmail.com';
    String adminPassword = 'admin123';
  try {    
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: adminEmail,
      password: adminPassword,
    );

    
    print('Admin account already exists.');
  } catch (e) {
    
       await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': adminEmail,
        'role': 'admin',
      });

    //   print('Admin account created successfully.');
    // } else {
    //   print('Error: $e');
    // }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await createAdminAccount();
  runApp(const MyApp());
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
      home: LoginPage(),
    );
  }
}