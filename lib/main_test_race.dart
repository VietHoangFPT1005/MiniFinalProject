import 'package:flutter/material.dart';
import 'package:prm232_mini_final_project/models/race_data.dart';
import 'package:prm232_mini_final_project/screens/race_screen.dart';

/// File test để mở thẳng RaceScreen
/// Chạy bằng: flutter run -t lib/main_test_race.dart

void main() {
  runApp(const TestRaceApp());
}

class TestRaceApp extends StatelessWidget {
  const TestRaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tạo dữ liệu test
    final testRaceData = RaceData(
      totalMoney: 1000,
      bets: [100, 200, 50], // Cược cho 3 xe
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test Race Screen',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: RaceScreen(raceData: testRaceData),
    );
  }
}
