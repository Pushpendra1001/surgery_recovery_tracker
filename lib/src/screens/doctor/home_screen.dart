import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:surgery_recovery_tracker/src/screens/doctor/patient_list_screen.dart';

class DoctorDashboard extends StatefulWidget {
  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> doctorData = {};
  List<Map<String, dynamic>> patients = [];

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
    _loadPatients();
  }

  Future<void> _loadDoctorData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doctorDoc = await _firestore.collection('doctors').doc(user.uid).get();
      setState(() {
        doctorData = doctorDoc.data() as Map<String, dynamic>;
      });
    }
  }

  Future<void> _loadPatients() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot patientSnapshot = await _firestore
          .collection('patients')
          .where('assignedDoctor', isEqualTo: user.uid)
          .get();

      setState(() {
        patients = patientSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDoctorInfoCard(),
              SizedBox(height: 20),
              Text(
                'Your Patients',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildPatientList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doctorData['name'] ?? 'Loading...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Role: Doctor'),
            Text('Specialization: ${doctorData['specialization'] ?? 'N/A'}'),
            Text('Hospital: ${doctorData['hospital'] ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        var patient = patients[index];
        return Card(
          child: ListTile(
            title: Text(patient['name']),
            subtitle: Text('Disease: ${patient['disease']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientDetailScreen(patientId: patient['uid']),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
