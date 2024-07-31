import 'package:flutter/material.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Text('Welcome to the Patient\'s Home Screen!'),
          Text('This is where you can view your recovery progress.'),
        ],
      ),
    );
  }
}