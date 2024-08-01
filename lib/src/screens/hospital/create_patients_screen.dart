import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:surgery_recovery_tracker/src/models/patient.dart';
import 'package:surgery_recovery_tracker/src/models/user.dart';
import 'package:surgery_recovery_tracker/src/services/firestore_service.dart';
import 'package:surgery_recovery_tracker/src/services/auth_service.dart';

class CreatePatientScreen extends StatefulWidget {
  @override
  _CreatePatientScreenState createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  final AuthService _auth = AuthService();
  final FirestoreService _db = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  List<Map<String, dynamic>> dailyTasks = [];
  bool agreementChecked = false;
  String? selectedDoctor;
  List<Map<String, String>> doctors = [];
  

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    QuerySnapshot querySnapshot = await _firestore.collection('doctors').get();
    setState(() {
      doctors = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': (doc.data() as Map<String, dynamic>)['name'] as String
              })
          .toList();
    });
  }

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
                  children: dailyTasks.map((task) => ListTile(
                    title: Text(task['description']),
                    trailing: Text('Day ${task['day']}'),
                  )).toList(),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Assign Doctor'),
                  value: selectedDoctor,
                  items: doctors.map((doctor) {
                    return DropdownMenuItem(
                      value: doctor['id'],
                      child: Text(doctor['name']!),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDoctor = newValue;
                    });
                  },
                  validator: (val) => val == null ? 'Please assign a doctor' : null,
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
    int taskDay = 1;
    bool applyForAllDays = false;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Daily Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newTask = value;
                },
                decoration: InputDecoration(hintText: "Enter task"),
              ),
              SizedBox(height: 10),
        
               
               Row(
                
              children: [
                       DropdownButton<int>(
                value: taskDay,
                items: List.generate(recoveryTimeInDays, (index) => index + 1)
                    .map((day) => DropdownMenuItem(value: day, child: Text('Day $day')))
                    .toList(),
                onChanged: (int? value) {
                  setState(() {
                    taskDay = value!;
                  });
                },
              ),
                Checkbox(
                  value: applyForAllDays,
                  onChanged: (bool? value) {
                    setState(() {
                      applyForAllDays = value ?? false;
                    });
                  },
                ),
                Text('Apply for all days'),
              ],
            ),
            ],
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
                  if (applyForAllDays) {
                    // Add task for all days
                    for (int i = 1; i <= recoveryTimeInDays; i++) {
                      dailyTasks.add({
                        'description': newTask,
                        'day': i,
                        'completed': false,
                      });
                    }
                  } else {
                    // Add task for a specific day
                    dailyTasks.add({
                      'description': newTask,
                      'day': taskDay,
                      'completed': false,
                    });
                  }
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
  if (_formKey.currentState!.validate() && startDate != null && selectedDoctor != null) {
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
        dailyTasks: dailyTasks.map((task) => task['description'] as String).toList(),
        assignedDoctor: selectedDoctor!,
      );

      UserModel userModel = UserModel(
        uid: user.uid,
        email: email,
        role: 'patient',
      );
      await _db.setUserData(userModel);
      await _db.addPatient(patient);
      
      // Generate recovery plan
      List<Map<String, dynamic>> recoveryPlan = [];
      for (int i = 0; i < recoveryTimeInDays; i++) {
        DateTime currentDate = startDate!.add(Duration(days: i));
        List<Map<String, dynamic>> dayTasks = dailyTasks.where((task) => task['day'] == i + 1).toList();
   
        double progressPercentage = ((i + 1) / recoveryTimeInDays) * 100;
        recoveryPlan.add({
          'date': currentDate,
          'tasks': dayTasks,
          'progressPercentage': progressPercentage.toStringAsFixed(2),
        });
      }
      
      // Save recovery plan to Firestore
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(user.uid)
          .collection('recoveryPlan')
          .doc('plan')
          .set({'plan': recoveryPlan});

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