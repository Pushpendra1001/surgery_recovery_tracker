import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surgery_recovery_tracker/src/models/user.dart';
import 'package:surgery_recovery_tracker/src/services/firestore_service.dart';
import 'package:surgery_recovery_tracker/src/services/auth_service.dart';

class CreateDoctorScreen extends StatefulWidget {
  @override
  _CreateDoctorScreenState createState() => _CreateDoctorScreenState();
}

class _CreateDoctorScreenState extends State<CreateDoctorScreen> {
  final AuthService _auth = AuthService();
  final FirestoreService _db = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String specialization = '';
  String hospital = '';
  bool agreementChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Doctor Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (val) => val!.isEmpty ? 'Please enter the doctor\'s name' : null,
                  onChanged: (val) => setState(() => name = val),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (val) => val!.isEmpty ? 'Please enter an email' : null,
                  onChanged: (val) => setState(() => email = val),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (val) => val!.isEmpty ? 'Please enter a password' : null,
                  onChanged: (val) => setState(() => password = val),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Specialization'),
                  validator: (val) => val!.isEmpty ? 'Please enter the specialization' : null,
                  onChanged: (val) => setState(() => specialization = val),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Hospital'),
                  validator: (val) => val!.isEmpty ? 'Please enter the hospital name' : null,
                  onChanged: (val) => setState(() => hospital = val),
                ),
                SizedBox(height: 20),
                CheckboxListTile(
                  title: Text('I agree to share my information with the hospital'),
                  value: agreementChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      agreementChecked = value!;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: agreementChecked ? _submitForm : null,
                  child: Text('Add Doctor'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      User? user = await _auth.registerWithEmailAndPassword(email, password);
      if (user != null) {
        Map<String, dynamic> doctorData = {
          'uid': user.uid,
          'name': name,
          'email': email,
          'specialization': specialization,
          'hospital': hospital,
        };
          UserModel userModel = UserModel(
          uid: user.uid,
          email: email,
          role: 'doctor',
        );
        await _db.setUserData(userModel);
        await _db.addDoctor(doctorData);

        _showCredentialsDialog();
      }
    }
  }

  void _showCredentialsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Doctor Account Created'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: $email'),
              Text('Password: $password'),
              SizedBox(height: 10),
              Text('Please provide these credentials to the doctor for login.'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); 
              },
            ),
          ],
        );
      },
    );
  }
}
