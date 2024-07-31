import 'package:flutter/material.dart';

class ChatWithDoctorScreen extends StatelessWidget {
  final String uid;

  ChatWithDoctorScreen({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Doctor'),
      ),
      body: Center(
        child: Text('Chat interface for patient $uid'),
      ),
    );
  }
}
