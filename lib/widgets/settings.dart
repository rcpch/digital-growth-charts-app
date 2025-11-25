import 'package:digital_growth_charts_app/definitions/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes/app_state.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  SwitchListTile buildFeatureFlag(
    AppState appState,
    FeatureFlag flag,
    bool enabled,
  ) {
    return SwitchListTile(
      title: Text(flag.name),
      value: enabled,
      onChanged: (bool value) {
        appState.setFeatureFlag(flag, value);
      },
    );
  }

  List<Widget> buildLoginTest(AppState appState) {
    if (appState.isFeatureFlagEnabled(FeatureFlag.login)) {
      if (appState.authData != null) {
        return [
          Column(children: [Text('Logged in as ${appState.authData!.email}')]),
          ElevatedButton(
            onPressed: () async {
              await appState.logout();
            },
            child: const Text('Logout'),
          ),
        ];
      }

      return [
        ElevatedButton(
          onPressed: () async {
            await appState.login();
          },
          child: const Text('Login'),
        ),
      ];
    } else {
      return [const SizedBox.shrink()];
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('RCPCH Growth Charts')),
      body: Column(
        children: [
          const Text(
            'Test new features 🚀',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Text(
            'WARNING: these features may not work at all and could crash!',
          ),
          ...FeatureFlag.values.map(
            (flag) => buildFeatureFlag(
              appState,
              flag,
              appState.isFeatureFlagEnabled(flag),
            ),
          ),
          ...buildLoginTest(appState),
        ],
      ),
    );
  }
}
