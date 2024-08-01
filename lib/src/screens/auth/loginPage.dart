
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surgery_recovery_tracker/src/screens/MainScreen/main_screen.dart';
import 'package:surgery_recovery_tracker/src/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
void dispose() {
  passwordController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
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
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
               
                  SizedBox(height: 32),
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.7,
                      child: ElevatedButton(
                       onPressed: () async {
                        print("Check");
                if (_formKey.currentState!.validate()) {
                  User? user = await _auth.signInWithEmailAndPassword(emailController.text, passwordController.text );
                  if (user != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen(),));
                  }
                }
              },
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
          ],
        ),
      ),
    );
  }
}