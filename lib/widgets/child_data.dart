import 'package:flutter/material.dart';

class ChildDataFormState extends State<ChildDataForm> {
  @override
  Widget build(BuildContext context) {
    return Text("child data form");
  }
}

class ChildDataForm extends StatefulWidget {
  const ChildDataForm({super.key});

  @override
  State<ChildDataForm> createState() => ChildDataFormState();
}