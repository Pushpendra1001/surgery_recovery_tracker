import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
  String hospital = '';
  DateTime? startDate;
  DateTime? endDate;
  List<String> dailyTasks = [];
  bool agreementChecked = false;

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  onChanged: (val) {
                    setState(() {
                      recoveryTimeInDays = int.parse(val);
                      if (startDate != null) {
                        endDate = startDate!.add(Duration(days: recoveryTimeInDays));
                      }
                    });
                  },
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
                TextFormField(
                  decoration: InputDecoration(labelText: 'Hospital'),
                  validator: (val) => val!.isEmpty ? 'Please enter the hospital name' : null,
                  onChanged: (val) => setState(() => hospital = val),
                ),
                SizedBox(height: 20),
                Text('Recovery Start Date:'),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        startDate = picked;
                        if (recoveryTimeInDays > 0) {
                          endDate = startDate!.add(Duration(days: recoveryTimeInDays));
                        }
                      });
                    }
                  },
                  child: Text(startDate == null ? 'Select Start Date' : DateFormat('yyyy-MM-dd').format(startDate!)),
                ),
                SizedBox(height: 10),
                Text('Recovery End Date: ${endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : 'Not set'}'),
                SizedBox(height: 20),
                Text('Daily Tasks:'),
                ElevatedButton(
                  onPressed: () {
                    _showAddTaskDialog();
                  },
                  child: Text('Add Daily Task'),
                ),
                Column(
                  children: dailyTasks.map((task) => ListTile(title: Text(task))).toList(),
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
                  child: Text('Add Patient'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    String newTask = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Daily Task'),
          content: TextField(
            onChanged: (value) {
              newTask = value;
            },
            decoration: InputDecoration(hintText: "Enter task"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (newTask.isNotEmpty) {
                  setState(() {
                    dailyTasks.add(newTask);
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && startDate != null) {
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
          hospital: hospital,
          startDate: startDate!,
          endDate: endDate!,
          dailyTasks: dailyTasks,
        );
        await _db.addPatient(patient);
        
        // Generate recovery plan
        List<Map<String, dynamic>> recoveryPlan = [];
        for (int i = 0; i < recoveryTimeInDays; i++) {
          DateTime currentDate = startDate!.add(Duration(days: i));
          double progressPercentage = ((i + 1) / recoveryTimeInDays) * 100;
          recoveryPlan.add({
            'date': currentDate,
            'tasks': dailyTasks,
            'progressPercentage': progressPercentage.toStringAsFixed(2),
          });
        }
        
        // Save recovery plan to Firestore
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(user.uid)
            .collection('recoveryPlan')
            .add({'plan': recoveryPlan});

        _showCredentialsDialog();
      }
    }
  }

  void _showCredentialsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Patient Account Created'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: $email'),
              Text('Password: $password'),
              SizedBox(height: 10),
              Text('Please provide these credentials to the patient for login.'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to previous screen
              },
            ),
          ],
        );
      },
    );
  }
}