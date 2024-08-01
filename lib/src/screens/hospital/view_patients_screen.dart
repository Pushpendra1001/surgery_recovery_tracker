import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewPatientsScreen extends StatefulWidget {
  @override
  _ViewPatientsScreenState createState() => _ViewPatientsScreenState();
}

class _ViewPatientsScreenState extends State<ViewPatientsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> patients = [];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      QuerySnapshot patientSnapshot = await _firestore.collection('patients').get();
      setState(() {
        patients = patientSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error loading patients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patients'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPatients,
        child: ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                title: Text(patient['name'] ?? 'Unknown'),
                subtitle: Text('Disease: ${patient['disease'] ?? 'N/A'}'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate to patient details screen if needed
                },
              ),
            );
          },
        ),
      ),
    );
  }
}