import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:blood_glucose_tracker/screens/blood_glucose_screen.dart';

@GenerateMocks([http.Client])
import 'blood_glucose_screen_test.mocks.dart';

void main() {
  group('Blood Glucose Screen Widget Test', () {
    testWidgets('Renders Blood Glucose Screen and interacts with date pickers',
        (WidgetTester tester) async {
      final mockHttpClient = MockClient();

      final mockResponseData = jsonEncode({
        'bloodGlucoseSamples': [
          {'value': '100', 'timestamp': '2024-09-28T10:00:00Z'},
          {'value': '110', 'timestamp': '2024-09-29T12:00:00Z'},
        ]
      });

      when(mockHttpClient.get(any)).thenAnswer((_) async {
        await Future.delayed(Duration(seconds: 2));
        return http.Response(mockResponseData, 200);
      });

      await tester.pumpWidget(MaterialApp(
        home: BloodGlucoseScreen(client: mockHttpClient),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Blood Glucose Tracker'), findsOneWidget);

      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('End Date'), findsOneWidget);

      await tester.tap(find.text('Start Date'));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarDatePicker), findsOneWidget);

      await tester.tap(find.text('End Date'));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarDatePicker), findsOneWidget);

      expect(find.byType(LineChart), findsOneWidget);
    });
  });
}
