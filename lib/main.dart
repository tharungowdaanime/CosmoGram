import 'package:flutter/material.dart';
// Makes sure your workspace links directly to your dashboard screen file
import './Screen.dart';

void main() {
  // 🚀 Starts the application by launching our custom themed space app wrapper
  runApp(const CosmoGramApp());
}

class CosmoGramApp extends StatelessWidget {
  const CosmoGramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CosmoGram',
      // Disables the red debug banner across the top corner of your screen
      debugShowCheckedModeBanner: false,

      // Enforces modern Material 3 global styling for cards, buttons, and fields
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(
          0xFF0C0E18,
        ), // Deep space background tint
      ),

      // Mounts the dashboard as our primary landing screen vector
      home: const CosmoGramDashboard(),
    );
  }
}
