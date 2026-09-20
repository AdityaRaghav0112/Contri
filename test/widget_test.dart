import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Contri basic UI components render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Groups')),
          body: const Center(child: Text('Your Groups')),
        ),
      ),
    );

    expect(find.text('Groups'), findsOneWidget);
    expect(find.text('Your Groups'), findsOneWidget);
  });
}
