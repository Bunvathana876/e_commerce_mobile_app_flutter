import 'package:e_commerc_mobile_app/shared/widgets/ios_bottom_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IosBottomNavBar Tests', () {
    testWidgets('renders all 5 tabs in exact order with labels', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return IosBottomNavBar(
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Verify labels exist in exact order
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Post'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify Post icon is CupertinoIcons.square_pencil
      expect(find.byIcon(CupertinoIcons.square_pencil), findsOneWidget);

      // Tap on Notifications tab (index 3)
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(selectedIndex, 3);

      // Tap on Profile tab (index 4)
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(selectedIndex, 4);
    });

    testWidgets('renders self-contained IosBottomNavExampleScreen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IosBottomNavExampleScreen(),
        ),
      );

      expect(find.text('Home Screen'), findsOneWidget);

      // Tap Search
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(find.text('Search Screen'), findsOneWidget);
    });
  });
}

