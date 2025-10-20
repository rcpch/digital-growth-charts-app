// libraries
import 'package:flutter/material.dart';

// RCPCH imports
import '/classes/app_config.dart';
import './themes/colours.dart';
import './widgets/input.dart';
import './widgets/home.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only load .env if dart-defines are not provided
  await AppConfig.init();
  runApp(const DGCApp());
}

class DGCApp extends StatelessWidget {
  const DGCApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RCPCH Digital Growth Charts',
      theme: DigitalGrowthChartsTheme.defaultTheme,
      home: HomeRoute(),
    );
  }
}
