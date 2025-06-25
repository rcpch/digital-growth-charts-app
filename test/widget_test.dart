// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:digital_growth_charts_app/main.dart';

void main() {
  testWidgets('Dummy test app mounts', (WidgetTester tester) async {
    await dotenv.load();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const DGCApp());

    // Dummy test to check everything is mounted
    expect(find.text('RCPCH Digital Growth Charts'), findsOneWidget);
  });
}