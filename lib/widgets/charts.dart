import 'package:flutter/material.dart';

class ChartsRoute extends StatelessWidget {
  const ChartsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'RCPCH Digital Growth Charts',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: const TabBarView(
          children: [
            Text("data"),
            Text("height"),
            Text("weight"),
            Text("bmi"),
            Text("head cm"),
            Text("sds"),
          ]
        ),
        bottomNavigationBar: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(icon: Icon(Icons.child_care)),
              Tab(text: "Height"),
              Tab(text: "Weight"),
              Tab(text: "BMI"),
              Tab(text: "Head cm."),
              Tab(text: "SDS"),
            ]
          )
      )
    );
  }
}