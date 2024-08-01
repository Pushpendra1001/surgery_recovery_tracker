import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewDoctorsScreen extends StatefulWidget {
  @override
  _ViewDoctorsScreenState createState() => _ViewDoctorsScreenState();
}

class _ViewDoctorsScreenState extends State<ViewDoctorsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> doctors = [];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      QuerySnapshot doctorSnapshot = await _firestore.collection('doctors').get();
      setState(() {
        doctors = doctorSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error loading doctors: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctors'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDoctors,
        child: ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                title: Text(doctor['name'] ?? 'Unknown'),
                subtitle: Text('Specialization: ${doctor['specialization'] ?? 'N/A'}'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate to doctor details screen if needed
                },
              ),
            );
          },
        ),
      ),
    );
  }
}