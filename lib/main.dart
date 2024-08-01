
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:surgery_recovery_tracker/firebase_options.dart';
import 'package:surgery_recovery_tracker/src/screens/auth/loginPage.dart';
import 'package:surgery_recovery_tracker/src/screens/hospital/dashboard_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/patient/patient_dashboard.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // await createAdmin();
  return runApp(const MyApp());
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
      home:  LoginPage(),
    );
  }
}

