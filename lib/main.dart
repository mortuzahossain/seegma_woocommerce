import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/ui/home/dashboard.dart';
import 'package:seegma_woocommerce/utils/themes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}
