import 'package:flutter/material.dart';
import 'package:gyatt_osc/tutorial/tutorial_gate_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TutorialGateScreen(),
    );
  }
}
