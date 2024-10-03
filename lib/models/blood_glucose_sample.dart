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
