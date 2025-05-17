// libraries
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// RCPCH imports
import './themes/colours.dart';
import './widgets/input.dart';

void main() async{
  await dotenv.load();
  runApp(const DGCApp());
}

class DGCApp extends StatelessWidget {
  const DGCApp({super.key});

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
          centerTitle: true,
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child:Column(
            children: const [
              InputForm(),
              const Padding(
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
