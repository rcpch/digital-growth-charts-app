import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RCPCH Growth Charts')),
      body: const Center(child: Text('Settings Page')),
    );
  }
}
