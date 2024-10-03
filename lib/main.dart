import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'screens/blood_glucose_screen.dart';

void main() {
  runApp(MyApp());
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
      home: BloodGlucoseScreen(client: http.Client()),
    );
  }
}
