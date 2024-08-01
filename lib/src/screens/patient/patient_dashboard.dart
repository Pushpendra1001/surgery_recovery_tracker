import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:surgery_recovery_tracker/src/screens/auth/loginPage.dart';
import 'package:surgery_recovery_tracker/src/screens/patient/progress_tracking_screen.dart';

class PatientDashboard extends StatefulWidget {
  @override
  _PatientDashboardState createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> patientData = {};
  List<dynamic> recoveryPlan = [];
  int daysRemaining = 0;
  double healingPercentage = 0.0;
  String healthStatus = 'Good';

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot patientDoc = await _firestore.collection('patients').doc(user.uid).get();
      setState(() {
        patientData = patientDoc.data() as Map<String, dynamic>;
      });

      QuerySnapshot planSnapshot = await _firestore
          .collection('patients')
          .doc(user.uid)
          .collection('recoveryPlan')
          .limit(1)
          .get();

      if (planSnapshot.docs.isNotEmpty) {
        setState(() {
          recoveryPlan = planSnapshot.docs.first['plan'] as List<dynamic>;
          _calculateProgress();
        });
      }
    }
  }

  void _calculateProgress() {
    DateTime now = DateTime.now();
    DateTime startDate = (patientData['startDate'] as Timestamp).toDate();
    DateTime endDate = (patientData['endDate'] as Timestamp).toDate();

    int totalDays = endDate.difference(startDate).inDays;
    int daysPassed = now.difference(startDate).inDays;

    setState(() {
      daysRemaining = totalDays - daysPassed;
      healingPercentage = (daysPassed / totalDays).clamp(0.0, 1.0);
      healthStatus = _determineHealthStatus();
    });
  }

  String _determineHealthStatus() {
    double taskCompletionRate = recoveryPlan.where((day) {
      return day['tasksCompleted'] == day['totalTasks'];
    }).length / recoveryPlan.length;

    if (taskCompletionRate > 0.8) return 'Excellent';
    if (taskCompletionRate > 0.6) return 'Good';
    if (taskCompletionRate > 0.4) return 'Fair';
    return 'Needs Improvement';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
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
              _buildPatientInfoCard(),
              SizedBox(height: 20),
              _buildTodaysTasks(),
              SizedBox(height: 20),
              _buildActionButtons(),
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
            Text('Hospital: ${patientData['hospital'] ?? 'N/A'}'),
            Text('Disease: ${patientData['disease'] ?? 'N/A'}'),
            Text('Start Date: ${_formatDate(patientData['startDate'])}'),
            Text('End Date: ${_formatDate(patientData['endDate'])}'),
            SizedBox(height: 8),
            Text('Days Remaining: $daysRemaining'),
            Text('Overall Progress: ${(healingPercentage * 100).toStringAsFixed(1)}%'),
            Text('Health Status: $healthStatus'),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysTasks() {
    List<dynamic> todaysTasks = _getTodaysTasks();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Tasks",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...todaysTasks.map((task) => _buildTaskCheckbox(task)).toList(),
          ],
        ),
      ),
    );
  }

  // Widget _buildTaskCheckbox(Map<String, dynamic> task) {
  //   return CheckboxListTile(
  //     title: Text(task['description']),
  //     value: task['completed'],
  //     onChanged: (bool? value) {
  //       setState(() {
  //         task['completed'] = value;
  //       });
  //       _updateTaskCompletion(task , value);
  //     },
  //   );
  // }
  Widget _buildTaskCheckbox(Map<String, dynamic> task) {
  return CheckboxListTile(
    title: Text(task['description']),
    value: task['completed'],
    onChanged: (bool? value) {
      _updateTaskCompletion(task, value);
    },
  );
}


  // Future<void> _updateTaskCompletion(Map<String, dynamic> task) async {
  //   User? user = _auth.currentUser;
  //   if (user != null) {
  //     await _firestore
  //         .collection('patients')
  //         .doc(user.uid)
  //         .collection('recoveryPlan')
  //         .doc(task['date'])
  //         .update({
  //       'tasks': FieldValue.arrayRemove([task]),
  //     });
  //     await _firestore
  //         .collection('patients')
  //         .doc(user.uid)
  //         .collection('recoveryPlan')
  //         .doc(task['date'])
  //         .update({
  //       'tasks': FieldValue.arrayUnion([task]),
  //     });
  //   }
    
  // }

  void _updateTaskCompletion(Map<String, dynamic> task, bool? value) async {
  User? user = _auth.currentUser;
  if (user != null) {
    // Update the local state
    setState(() {
      task['completed'] = value;
    });

    // Update the task in Firestore
    await _firestore.runTransaction((transaction) async {
      DocumentReference taskDocRef = _firestore
          .collection('patients')
          .doc(user.uid)
          .collection('recoveryPlan')
          .doc(task['date']);
      
      DocumentSnapshot taskDocSnapshot = await transaction.get(taskDocRef);
      if (taskDocSnapshot.exists) {
        List<dynamic> tasks = taskDocSnapshot['tasks'];
        int taskIndex = tasks.indexWhere((t) => t['description'] == task['description']);
        if (taskIndex != -1) {
          tasks[taskIndex]['completed'] = value;
          transaction.update(taskDocRef, {'tasks': tasks});
        }
      }
    });
  }
}


  

  

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.track_changes),
          label: Text('Track Progress'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TrackingPage(recoveryPlan: recoveryPlan)),
            );
          },
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.chat),
          label: Text('Chat with Doctor'),
          onPressed: () {
            // Implement chat functionality
          },
        ),
      ],
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime date = (timestamp as Timestamp).toDate();
    return DateFormat('yyyy-MM-dd').format(date);
  }

  List<dynamic> _getTodaysTasks() {
    DateTime now = DateTime.now();
    for (var day in recoveryPlan) {
      DateTime date = (day['date'] as Timestamp).toDate();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return day['tasks'];
      }
    }
    return [];
  }
}
