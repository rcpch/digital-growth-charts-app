// libraries
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// RCPCH imports
import './themes/colours.dart';
import './widgets/input.dart';

void main() async{
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RCPCH Digital Growth Charts',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('RCPCH Digital Growth Charts'),
        ),
        body: Center(
          child: InputForm()
        )
    )
    );
  }
}
