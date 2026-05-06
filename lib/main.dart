// libraries
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

// RCPCH imports
import '/classes/app_config.dart';
import './themes/colours.dart';
import './widgets/input.dart';
import './classes/app_state.dart';
import './widgets/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only load .env if dart-defines are not provided
  await AppConfig.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  runApp(const DGCApp());
}

class DGCApp extends StatelessWidget {
  const DGCApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var state = AppState();
    state.loadAuthData();

    return ChangeNotifierProvider(
      create: (_) => state,
      child: MaterialApp(
        title: 'RCPCH Growth Charts',
        theme: DigitalGrowthChartsTheme.defaultTheme,
        home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'RCPCH Growth Charts',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: <Widget>[
              // Needs to be a sub-widget to use the Navigator provider by MaterialApp
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Settings()),
                    );
                  },
                ),
              ),
            ],
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
        ),
      ),
    );
  }
}
