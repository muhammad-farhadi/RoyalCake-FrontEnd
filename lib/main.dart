import 'package:flutter/material.dart';
import 'package:royalcakes/pages/HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Royal Cakes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(1, 12, 77, 59)),
      ),
      debugShowCheckedModeBanner: false,
      home: const Homepage(),
    );
  }
}
