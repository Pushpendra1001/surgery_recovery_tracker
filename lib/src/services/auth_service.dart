import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surgery_recovery_tracker/src/screens/auth/login_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  User? get currentUser {
    return _firebaseAuth.currentUser;
  }
  // Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Sign in with email and password
  // Future<User?> signInWithEmailAndPassword(String email, String password) async {
  //   try {
  //     UserCredential userCredential = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return userCredential.user;
  //   } catch (e) {
  //     print('Error: $e');
  //     return null;
  //   }
  // }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    print("Logged out");
    
  }
}
