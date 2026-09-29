import 'package:flutter/material.dart';
import 'app_shell.dart';

void main() {
  runApp(const TontineApp());
}

class TontineApp extends StatelessWidget {
  const TontineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tontine Famille Bamiléké',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E5E4E),
        scaffoldBackgroundColor: const Color(0xFFF7FAF9),
        fontFamily: 'sans-serif',
      ),
      home: const AppShell(),
    );
  }
}