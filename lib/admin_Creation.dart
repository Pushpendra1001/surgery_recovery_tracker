import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:surgery_recovery_tracker/main.dart';
import 'package:surgery_recovery_tracker/src/services/auth_service.dart';
import 'package:surgery_recovery_tracker/src/services/firestore_service.dart';



// Call this function once to create the admin account
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await createAdmin();
  runApp(MyApp());
}
