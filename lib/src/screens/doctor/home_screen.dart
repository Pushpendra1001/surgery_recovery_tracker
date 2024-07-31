import 'package:flutter/material.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Text('Welcome to the Doctor\'s Home Screen!'),
          Text('This is where you can view your patients\' recovery progress.'),
        ],
      ),
    );
  }
}