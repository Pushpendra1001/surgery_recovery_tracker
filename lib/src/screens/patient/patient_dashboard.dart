import 'package:flutter/material.dart';
import 'package:surgery_recovery_tracker/src/models/user.dart';
import 'package:surgery_recovery_tracker/src/screens/patient/chat_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/patient/progress_tracking_screen.dart';

import 'package:surgery_recovery_tracker/src/services/firestore_service.dart';

class PatientDashboard extends StatelessWidget {
  final String uid;
  final FirestoreService _db = FirestoreService();

  PatientDashboard({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Dashboard'),
      ),
      body: FutureBuilder<UserModel?>(
        future: _db.getUserByUid(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          UserModel? patient = snapshot.data;
          return patient == null
              ? Center(child: Text('No patient data found'))
              : Column(
                  children: [
                    Text('Name: ${patient.name}'),
                    Text('Disease: ${patient.disease}'),
                    Text('Recovery Time: ${patient.recoveryTimeInDays} days'),
                    Text('Recovery Checklist: ${patient.recoveryChecklist}'),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProgressChartScreen(uid: uid)),
                        );
                      },
                      child: Text('View Progress Chart'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatWithDoctorScreen(uid: uid)),
                        );
                      },
                      child: Text('Chat with Doctor'),
                    ),
                  ],
                );
        },
      ),
    );
  }
}