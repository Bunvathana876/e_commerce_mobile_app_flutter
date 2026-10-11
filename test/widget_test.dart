// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:e_commerc_mobile_app/app/app.dart';
import 'package:e_commerc_mobile_app/features/auth/providers/auth_provider.dart';

void main() {
  testWidgets('App launches and renders Welcome Screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
        child: const MyApp(),
      ),
    );

    // Verify welcome screen elements render
    expect(find.text('Blue Panda'), findsOneWidget);
    expect(find.text('Welcome to Blue Panda'), findsOneWidget);
    expect(find.text('Continue with email'), findsOneWidget);
  });
}
