import 'package:flutter/material.dart';
import 'package:quiz_app2/pages/question_page.dart';
import 'package:quiz_app2/pages/result_page.dart';
import 'package:quiz_app2/pages/splashpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      home: Splashpage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
