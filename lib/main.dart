import 'package:flutter/material.dart';
import 'package:jokerly/pages/home.dart';

void main() {
  runApp(const JokerlyApp());
}

class JokerlyApp extends StatelessWidget {
  const JokerlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jokerly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'KGRedHands',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2a2a2a)),
        useMaterial3: true,
        canvasColor: Colors.transparent,
      ),
      home: const HomePage(),
    );
  }
}
