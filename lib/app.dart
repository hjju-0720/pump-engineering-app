import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_page.dart';

class PumpEngineeringApp extends StatelessWidget {
  const PumpEngineeringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pump Engineering App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const DashboardPage(),
    );
  }
}
