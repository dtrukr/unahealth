import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class BloodGlucoseSample {
  final double value;
  final DateTime timestamp;

  BloodGlucoseSample({required this.value, required this.timestamp});

  factory BloodGlucoseSample.fromJson(Map<String, dynamic> json) {
    return BloodGlucoseSample(
      value: double.parse(json['value']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Glucose Tracker',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF1E1E2C),
        primaryColor: Color(0xFF00D1FF),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF00D1FF),
          secondary: Color(0xFF64FFDA),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        ),
      ),
      home: BloodGlucoseScreen(),
    );
  }
}

class BloodGlucoseScreen extends StatefulWidget {
  @override
  _BloodGlucoseScreenState createState() => _BloodGlucoseScreenState();
}

class _BloodGlucoseScreenState extends State<BloodGlucoseScreen> {
  List<BloodGlucoseSample> samples = [];
  DateTime? startDate;
  DateTime? endDate;
  bool loading = false;

  Future<List<BloodGlucoseSample>> fetchBloodGlucoseData() async {
    final response = await http.get(Uri.parse(
        'https://s3-de-central.profitbricks.com/una-health-frontend-tech-challenge/sample.json'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return (jsonData['bloodGlucoseSamples'] as List)
          .map((data) => BloodGlucoseSample.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  void filterData() {
    if (startDate != null && endDate != null) {
      setState(() {
        samples = samples
            .where((sample) =>
                sample.timestamp.isAfter(startDate!) && sample.timestamp.isBefore(endDate!))
            .toList();
      });
    }
  }

  double get minValue =>
      samples.isEmpty ? 0 : samples.map((e) => e.value).reduce((a, b) => a < b ? a : b);
  double get maxValue =>
      samples.isEmpty ? 0 : samples.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  double get averageValue =>
      samples.isEmpty ? 0 : samples.map((e) => e.value).reduce((a, b) => a + b) / samples.length;
  double get medianValue {
    if (samples.isEmpty) return 0;
    var sortedValues = samples.map((e) => e.value).toList()..sort();
    int middle = sortedValues.length ~/ 2;
    return sortedValues.length % 2 == 1
        ? sortedValues[middle]
        : (sortedValues[middle - 1] + sortedValues[middle]) / 2;
  }

  @override
  void initState() {
    super.initState();
    loading = true;
    fetchBloodGlucoseData().then((data) {
      setState(() {
        samples = data;
        loading = false;
      });
    });
  }

  Widget buildChart() {
    return LineChart(
      LineChartData(
        backgroundColor: Color(0xFF2C2C40),
        borderData: FlBorderData(show: true, border: Border.all(color: Color(0xFF3C3C56))),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) => FlLine(color: Color(0xFF3C3C56), strokeWidth: 0.5),
          getDrawingVerticalLine: (value) => FlLine(color: Color(0xFF3C3C56), strokeWidth: 0.5),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: samples
                .map((sample) =>
                    FlSpot(sample.timestamp.millisecondsSinceEpoch.toDouble(), sample.value))
                .toList(),
            isCurved: true,
            color: Color(0xFF00D1FF),
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, _) {
                return Text(value.toStringAsFixed(1),
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text(DateFormat('MM/dd').format(date),
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStatCard(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C40),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(value,
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Glucose Tracker',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF1E1E2C),
        elevation: 0,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 250, child: buildChart()),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.calendar_today, color: Colors.white),
                            label: Text('Start Date', style: TextStyle(color: Colors.white)),
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2025),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.dark(
                                          primary: Color(0xFF00D1FF),
                                          surface: Color(0xFF1E1E2C),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  });
                              if (picked != null) {
                                setState(() {
                                  startDate = picked;
                                });
                                filterData();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF00D1FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.calendar_today, color: Colors.white),
                            label: Text('End Date', style: TextStyle(color: Colors.white)),
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2025),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.dark(
                                          primary: Color(0xFF00D1FF),
                                          surface: Color(0xFF1E1E2C),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  });
                              if (picked != null) {
                                setState(() {
                                  endDate = picked;
                                });
                                filterData();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF00D1FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        buildStatCard('Minimum', minValue.toStringAsFixed(2), Colors.greenAccent),
                        buildStatCard('Maximum', maxValue.toStringAsFixed(2), Colors.redAccent),
                        buildStatCard(
                            'Average', averageValue.toStringAsFixed(2), Colors.blueAccent),
                        buildStatCard(
                            'Median', medianValue.toStringAsFixed(2), Colors.purpleAccent),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
