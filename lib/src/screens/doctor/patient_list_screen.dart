import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;

  PatientDetailScreen({required this.patientId});

  @override
  _PatientDetailScreenState createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> patientData = {};
  List<Map<String, dynamic>> recoveryPlan = [];

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

 Future<void> _loadPatientData() async {
  try {
    DocumentSnapshot patientDoc = await _firestore.collection('patients').doc(widget.patientId).get();
    if (patientDoc.exists) {
      setState(() {
        patientData = patientDoc.data() as Map<String, dynamic>? ?? {};
      });

      QuerySnapshot planSnapshot = await _firestore
          .collection('patients')
          .doc(widget.patientId)
          .collection('recoveryPlan')
          .limit(1)
          .get();

      if (planSnapshot.docs.isNotEmpty) {
        var planData = planSnapshot.docs.first.data() as Map<String, dynamic>?;
        if (planData != null) {
          var planList = planData['plan'] as List<dynamic>? ?? [];
          setState(() {
            recoveryPlan = planList.whereType<Map<String, dynamic>>().toList();
          });
        }
      }
    }
  } catch (e) {
    print('Error loading patient data: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientInfoCard(),
              SizedBox(height: 20),
              Text(
                'Recovery Plan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildRecoveryPlan(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patientData['name'] ?? 'Loading...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Disease: ${patientData['disease'] ?? 'N/A'}'),
            Text('Hospital: ${patientData['hospital'] ?? 'N/A'}'),
            Text('Start Date: ${_formatDate(patientData['startDate'])}'),
            Text('End Date: ${_formatDate(patientData['endDate'])}'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryPlan() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: recoveryPlan.length,
      itemBuilder: (context, index) {
        var day = recoveryPlan[index];
        return Card(
          child: ExpansionTile(
            title: Text('Day ${index + 1}: ${_formatDate(day['date'])}'),
            children: [
              ...day['tasks'].map<Widget>((task) => ListTile(
                title: Text(task['description']),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editTask(index, task),
                ),
              )).toList(),
              ButtonBar(
                children: [
                  ElevatedButton(
                    child: Text('Add Task'),
                    onPressed: () => _addTask(index),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime date = (timestamp as Timestamp).toDate();
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void _editTask(int dayIndex, Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String updatedTask = task['description'];
        return AlertDialog(
          title: Text('Edit Task'),
          content: TextField(
            onChanged: (value) {
              updatedTask = value;
            },
            controller: TextEditingController(text: task['description']),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  recoveryPlan[dayIndex]['tasks'][recoveryPlan[dayIndex]['tasks'].indexOf(task)]['description'] = updatedTask;
                });
                _updateRecoveryPlan();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addTask(int dayIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTask = '';
        return AlertDialog(
          title: Text('Add New Task'),
          content: TextField(
            onChanged: (value) {
              newTask = value;
            },
            decoration: InputDecoration(hintText: "Enter new task"),
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
                    recoveryPlan[dayIndex]['tasks'].add({
                      'description': newTask,
                      'completed': false,
                    });
                  });
                  _updateRecoveryPlan();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

Future<void> _updateRecoveryPlan() async {
  try {
    // Reference to the specific patient document's recoveryPlan subcollection
    CollectionReference recoveryPlanRef = _firestore
        .collection('patients')
        .doc(widget.patientId)
        .collection('recoveryPlan');

    // Assuming each day has a unique document ID, use a method to update all days
    for (var i = 0; i < recoveryPlan.length; i++) {
      var dayData = recoveryPlan[i];
      // Document ID should be set to a unique identifier; here, we use the patient's ID and day index
      await recoveryPlanRef
          .doc('day_$i') // Replace with your document ID strategy if different
          .set({'plan': dayData});
    }
  } catch (e) {
    print('Error updating recovery plan: $e');
  }
}

}
