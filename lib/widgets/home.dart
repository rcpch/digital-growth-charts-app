import 'package:digital_growth_charts_app/widgets/input.dart';
import 'package:flutter/material.dart';

class HomeRoute extends StatelessWidget {
  const HomeRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'RCPCH Digital Growth Charts',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
            ],
          ),
        ),
      );
  }
}