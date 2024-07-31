import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:surgery_recovery_tracker/src/models/patient.dart';
import 'package:surgery_recovery_tracker/src/services/firestore_service.dart';
import 'package:surgery_recovery_tracker/src/services/auth_service.dart';

class CreatePatientScreen extends StatefulWidget {
  @override
  _CreatePatientScreenState createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  final AuthService _auth = AuthService();
  final FirestoreService _db = FirestoreService();

  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String disease = '';
  int recoveryTimeInDays = 0;
  String recoveryChecklist = '';
  String exerciseType = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Patient Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (val) => val!.isEmpty ? 'Please enter the patient name' : null,
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
                  decoration: InputDecoration(labelText: 'Disease'),
                  validator: (val) => val!.isEmpty ? 'Please enter the disease' : null,
                  onChanged: (val) => setState(() => disease = val),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Recovery Time (days)'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? 'Please enter recovery time in days' : null,
                  onChanged: (val) => setState(() => recoveryTimeInDays = int.parse(val)),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Recovery Checklist'),
                  validator: (val) => val!.isEmpty ? 'Please enter recovery checklist' : null,
                  onChanged: (val) => setState(() => recoveryChecklist = val),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Exercise Type'),
                  validator: (val) => val!.isEmpty ? 'Please enter exercise type' : null,
                  onChanged: (val) => setState(() => exerciseType = val),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      User? user = await _auth.registerWithEmailAndPassword(email, password);
                      if (user != null) {
                        PatientModel patient = PatientModel(
                          uid: user.uid,
                          name: name,
                          email: email,
                          disease: disease,
                          recoveryTimeInDays: recoveryTimeInDays,
                          recoveryChecklist: recoveryChecklist,
                          exerciseType: exerciseType,
                          password: password,
                          
                        );
                        await _db.addPatient(patient);
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text('Add Patient'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
