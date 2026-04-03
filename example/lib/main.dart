// lib/main.dart

import 'package:example/features/login/login_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(const FluxFormDemoApp());

class FluxFormDemoApp extends StatelessWidget {
  const FluxFormDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flux Form Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
