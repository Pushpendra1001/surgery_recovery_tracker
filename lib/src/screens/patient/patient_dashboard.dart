import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
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
  List<Map<String, dynamic>> recoveryPlan = [];
  int daysRemaining = 0;
  double healingPercentage = 0.0;
  String healthStatus = 'Good';

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot patientDoc = await _firestore.collection('patients').doc(user.uid).get();
        if (patientDoc.exists) {
          setState(() {
            patientData = patientDoc.data() as Map<String, dynamic>? ?? {};
          });

          QuerySnapshot planSnapshot = await _firestore
              .collection('patients')
              .doc(user.uid)
              .collection('recoveryPlan')
              .limit(1)
              .get();

          if (planSnapshot.docs.isNotEmpty) {
            var planData = planSnapshot.docs.first.data() as Map<String, dynamic>?;
            if (planData != null) {
              var planList = planData['plan'] as List<dynamic>? ?? [];
              setState(() {
                recoveryPlan = planList.whereType<Map<String, dynamic>>().toList();
                _calculateProgress();
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error loading patient data: $e');
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
    int completedTasks = 0;
    int totalTasks = 0;

    for (var day in recoveryPlan) {
      List<dynamic> tasks = day['tasks'] ?? [];
      completedTasks += tasks.where((task) => task['completed'] == true).length;
      totalTasks += tasks.length;
    }

    double taskCompletionRate = totalTasks > 0 ? completedTasks / totalTasks : 0;

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
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPatientData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPatientInfoCard(),
                SizedBox(height: 20),
                _buildProgressIndicator(),
                SizedBox(height: 20),
                _buildTodaysTasks(),
                SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            _buildInfoRow(Icons.local_hospital, 'Hospital', patientData['hospital'] ?? 'N/A'),
            _buildInfoRow(Icons.medical_services, 'Disease', patientData['disease'] ?? 'N/A'),
            _buildInfoRow(Icons.calendar_today, 'Start Date', _formatDate(patientData['startDate'])),
            _buildInfoRow(Icons.event, 'End Date', _formatDate(patientData['endDate'])),
            SizedBox(height: 8),
            _buildInfoRow(Icons.timer, 'Days Remaining', '$daysRemaining'),
            _buildInfoRow(Icons.favorite, 'Health Status', healthStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            LinearPercentIndicator(
              lineHeight: 20.0,
              percent: healingPercentage,
              center: Text(
                '${(healingPercentage * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.grey[300],
              progressColor: Colors.blue,
              animation: true,
              animationDuration: 1000,
              barRadius: Radius.circular(10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysTasks() {
    List<Map<String, dynamic>> todaysTasks = _getTodaysTasks();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            if (todaysTasks.isEmpty)
              Text('No tasks for today.', style: TextStyle(fontStyle: FontStyle.italic))
            else
              ...todaysTasks.map((task) => _buildTaskCheckbox(task)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCheckbox(Map<String, dynamic> task) {
    return CheckboxListTile(
      title: Text(task['description']),
      value: task['completed'],
      onChanged: (bool? value) {
        _updateTaskCompletion(task, value);
      },
      activeColor: Colors.blue,
    );
  }

  void _updateTaskCompletion(Map<String, dynamic> task, bool? value) async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        task['completed'] = value;
      });

      int dayIndex = recoveryPlan.indexWhere((day) => 
        day['tasks'].any((t) => t['description'] == task['description'])
      );

      if (dayIndex != -1) {
        int taskIndex = recoveryPlan[dayIndex]['tasks'].indexWhere((t) => t['description'] == task['description']);
        recoveryPlan[dayIndex]['tasks'][taskIndex]['completed'] = value;

        await _updateRecoveryPlan();
      }

      _calculateProgress();
    }
  }

  Future<void> _updateRecoveryPlan() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        CollectionReference recoveryPlanRef = _firestore
            .collection('patients')
            .doc(user.uid)
            .collection('recoveryPlan');

        await recoveryPlanRef.doc('currentPlan').set({'plan': recoveryPlan});
      }
    } catch (e) {
      print('Error updating recovery plan: $e');
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
          style: ElevatedButton.styleFrom(
            
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.chat),
          label: Text('Chat with Doctor'),
          onPressed: () {
            // Implement chat functionality
          },
          style: ElevatedButton.styleFrom(
            
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime date = (timestamp as Timestamp).toDate();
    return DateFormat('yyyy-MM-dd').format(date);
  }

  List<Map<String, dynamic>> _getTodaysTasks() {
    DateTime now = DateTime.now();
    for (var day in recoveryPlan) {
      DateTime date = (day['date'] as Timestamp).toDate();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return List<Map<String, dynamic>>.from(day['tasks'] ?? []);
      }
    }
    return [];
  }
}