import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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


            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Number of Tasks Per Day" ,style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20) ),
            ),


            _buildTasksPerDayChart(),
                 Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Daily Progress Growth Chart" , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20),  ),
            ),
            _buildGrowthChart(),
            _buildHealthStatusCard(),
            _buildDailyProgressList(),
          ],
        ),
      ),
    );
  }

   Widget _buildGoalCompletionChart() {
    var today = DateTime.now();
    var todayPlan = recoveryPlan.firstWhere(
      (day) => DateTime.parse(day['date']).day == today.day,
      orElse: () => null,
    );

    if (todayPlan == null) {
      return Text("No tasks for today");
    }

    double completedTasks = todayPlan['tasks'].where((task) => task['completed'] == true).length.toDouble();
    double totalTasks = todayPlan['tasks'].length.toDouble();
    double completionPercentage = (completedTasks / totalTasks);

    return CircularPercentIndicator(
      radius: 100.0,
      lineWidth: 10.0,
      percent: completionPercentage,
      center: new Text("${(completionPercentage * 100).toStringAsFixed(1)}%"),
      progressColor: Colors.green,
    );
  }

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
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: taskCount.toDouble(),
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });

    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          barGroups: barGroups,
          minY: 0,
          maxY: recoveryPlan.fold(0, (max, day) => (day['tasks'] as List).length > max ? (day['tasks'] as List).length : max).toDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toString(),
                  TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
Widget _buildGrowthChart() {
  return Container(
    height: 400,
    padding: EdgeInsets.all(16),
    child: LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}%');
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('Day ${value.toInt() + 1}');
              },
            ),
          ),
        ),
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
              double completedTasks = day['tasks'].where((task) => task['completed'] == true).length.toDouble();
              double totalTasks = day['tasks'].length.toDouble();
              double taskCompletionPercentage = (completedTasks / totalTasks) * 100;
              return FlSpot(index.toDouble(), taskCompletionPercentage);
            }),
            isCurved: true,
            color: Colors.green,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.3)),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            
            getTooltipItems: (spots) {
              return spots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)}%',
                  TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    ),
  );
}
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

  Widget _buildDailyProgressList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: recoveryPlan.length,
      itemBuilder: (context, index) {
        var day = recoveryPlan[index];
        DateTime date = (day['date'] as Timestamp).toDate();
        List tasks = day['tasks'];
        int completedTasks = tasks.where((task) => task['completed']).length;
        double progress = (completedTasks / tasks.length) * 100;

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
                ...tasks.map((task) => CheckboxListTile(
                      title: Text(task['description']),
                      value: task['completed'],
                      onChanged: null,
                    )).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  String _calculateOverallStatus() {
    double averageProgress = recoveryPlan.map((day) {
      List tasks = day['tasks'];
      int completedTasks = tasks.where((task) => task['completed']).length;
      double progressPercentage = (completedTasks / tasks.length) * 100;
      return progressPercentage;
    }).reduce((a, b) => a + b) / recoveryPlan.length;

    if (averageProgress > 80) return 'Excellent';
    if (averageProgress > 60) return 'Good';
    if (averageProgress > 40) return 'Fair';
    return 'Needs Improvement';
  }

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