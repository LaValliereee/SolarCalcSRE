import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'screens/home/home_screen.dart';

/// Widget root aplikasi SolaCalcSRE.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SolaCalcSRE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}