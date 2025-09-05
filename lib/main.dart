// libraries
import 'package:flutter/material.dart';

// RCPCH imports
import '/classes/app_config.dart';
import './themes/colours.dart';
import './widgets/input.dart';

void main() async{
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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('RCPCH Digital Growth Charts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child:Column(
            children: const [
              InputForm(),
              Padding(
                padding: EdgeInsets.all(30),
                child: Image(
                  image: AssetImage('assets/images/incubator_alpha.png'),
                  fit: BoxFit.fitWidth,
                  width: 150,
                ),
              ),
            ]
          )
        )
      )
    );
  }
}
