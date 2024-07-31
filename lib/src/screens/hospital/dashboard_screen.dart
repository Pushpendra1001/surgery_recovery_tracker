import 'package:flutter/material.dart';
import 'package:surgery_recovery_tracker/src/models/patient.dart';
import 'package:surgery_recovery_tracker/src/screens/hospital/create_patients_screen.dart';

import 'package:surgery_recovery_tracker/src/services/firestore_service.dart';

class AdminDashboard extends StatelessWidget {
  final FirestoreService _db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreatePatientScreen()),
              );
            },
            child: Text('Add Patient'),
          ),
          Expanded(
            child: StreamBuilder<List<PatientModel>>(
              stream: _db.getPatients(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                List<PatientModel> patients = snapshot.data!;
                return ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    PatientModel patient = patients[index];
                    return ListTile(
                      title: Text(patient.name),
                      subtitle: Text(patient.disease),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // _db.deletePatient(patient.uid);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
