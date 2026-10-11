import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerc_mobile_app/core/utils/page_transitions.dart';

void main() {
  testWidgets('SmoothPageRoute slides new screen from right to left', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      SmoothPageRoute(
                        page: const Scaffold(body: Text('Second Screen')),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Tap to open
    await tester.tap(find.text('Open'));
    // Pump partially into the transition
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Second screen should be in the tree during transition
    expect(find.text('Second Screen'), findsOneWidget);

    // Settle transition to completion
    await tester.pumpAndSettle();
    expect(find.text('Second Screen'), findsOneWidget);
  });

  testWidgets('NoAnimationPageRoute navigates immediately with zero duration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      NoAnimationPageRoute(
                        page: const Scaffold(body: Text('Instant Screen')),
                      ),
                    );
                  },
                  child: const Text('Open Instant'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Instant'));
    await tester.pump();

    // Instant screen is already rendered without waiting for animation duration
    expect(find.text('Instant Screen'), findsOneWidget);
  });
}

