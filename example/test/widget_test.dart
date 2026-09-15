import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:authyo_plugin_example/main.dart';

void main() {
  testWidgets('demo page renders the style picker', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Dialog design'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<dynamic>), findsNothing);
    expect(find.text('Follow dashboard'), findsOneWidget);
  });
}
