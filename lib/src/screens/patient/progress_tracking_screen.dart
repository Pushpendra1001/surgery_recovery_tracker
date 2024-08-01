import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class TrackingPage extends StatelessWidget {
  final List<dynamic> recoveryPlan;

  TrackingPage({required this.recoveryPlan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Tracking'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            
            _buildTasksPerDayChart(),
            _buildGrowthChart(),
            _buildHealthStatusCard(),
            _buildDailyProgressList(),
          ],
        ),
      ),
    );
  }

 
 

  // Bar Chart for Number of Tasks Per Day
  Widget _buildTasksPerDayChart() {
    List<BarChartGroupData> barGroups = List.generate(recoveryPlan.length, (index) {
      var day = recoveryPlan[index];
      int taskCount = (day['tasks'] as List).length;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: taskCount.toDouble(),
            color: Colors.blue,
            width: 16,
          ),
        ],
      );
    });

    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          barGroups: barGroups,
          minY: 0,
          maxY: recoveryPlan.fold(0, (max, day) => (day['tasks'] as List).length > max ? (day['tasks'] as List).length : max).toDouble(),
        ),
      ),
    );
  }

  // Line Chart for Growth Based on Tasks
  Widget _buildGrowthChart() {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: recoveryPlan.length.toDouble() - 1,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(recoveryPlan.length, (index) {
                var day = recoveryPlan[index];
                double progressPercentage = double.tryParse(day['progressPercentage'].toString()) ?? 0.0;
                double growthFactor = (day['tasks'].length * 2).toDouble();
                return FlSpot(index.toDouble(), progressPercentage + growthFactor);
              }),
              isCurved: true,
              color: Colors.green,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.3)),
            ),
          ],
        ),
      ),
    );
  }

  // Overall Health Status Card
  Widget _buildHealthStatusCard() {
    String overallStatus = _calculateOverallStatus();
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overall Health Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(overallStatus, style: TextStyle(fontSize: 24, color: _getStatusColor(overallStatus))),
            SizedBox(height: 8),
            
          ],
        ),
      ),
    );
  }

  // Daily Progress List
  Widget _buildDailyProgressList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: recoveryPlan.length,
      itemBuilder: (context, index) {
        var day = recoveryPlan[index];
        DateTime date = (day['date'] as Timestamp).toDate();
        double progress = double.tryParse(day['progressPercentage'].toString()) ?? 0.0;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${index + 1}: ${DateFormat('yyyy-MM-dd').format(date)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                LinearPercentIndicator(
                  width: MediaQuery.of(context).size.width - 64,
                  lineHeight: 14.0,
                  percent: progress / 100,
                  center: Text("${progress.toStringAsFixed(1)}%"),
                  backgroundColor: Colors.grey[300],
                  progressColor: Colors.blue,
                ),
                SizedBox(height: 8),
                Text('Tasks:'),
                ...day['tasks'].map((task) => CheckboxListTile(
                      title: Text(task['description']),
                      value: task['completed'],
                      onChanged: null,  // Read-only in tracking page
                    )).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  // Calculate Overall Status
  String _calculateOverallStatus() {
    double averageProgress = recoveryPlan.map((day) {
      double progressPercentage = double.tryParse(day['progressPercentage'].toString()) ?? 0.0;
      return progressPercentage;
    }).reduce((a, b) => a + b) / recoveryPlan.length;

    if (averageProgress > 80) return 'Excellent';
    if (averageProgress > 60) return 'Good';
    if (averageProgress > 40) return 'Fair';
    return 'Needs Improvement';
  }

  // Get Status Color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Fair':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}
