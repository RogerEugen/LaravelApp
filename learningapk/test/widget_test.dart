import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapk/src/widgets/common.dart';

void main() {
  testWidgets('Laravel brand mark renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LaravelMark())),
    );

    expect(find.byIcon(Icons.code_rounded), findsOneWidget);
  });
}
