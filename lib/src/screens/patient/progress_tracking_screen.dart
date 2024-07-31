import 'package:flutter/material.dart';

class ProgressChartScreen extends StatelessWidget {
  final String uid;

  ProgressChartScreen({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Chart'),
      ),
      body: Center(
        child: Text('Progress chart for patient $uid'),
      ),
    );
  }
}
