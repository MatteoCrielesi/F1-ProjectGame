// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

//import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:f1_project/main.dart';

void main() {
  testWidgets('App starts and shows splash screen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const F1App());

    // Verify that the splash screen is shown by checking for the presence of the logo.
    expect(find.byType(SvgPicture), findsOneWidget);

    // Wait for animations to complete
    await tester.pump(const Duration(seconds: 1));

    // Verify that after animations, we are still on the splash screen (or transitioned as expected)
    expect(find.byType(SvgPicture), findsOneWidget);
  });
}
