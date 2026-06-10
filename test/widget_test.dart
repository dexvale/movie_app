import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/main.dart';

void main() {
  testWidgets('FlixNoir mobile app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title logo elements exist
    expect(find.text('FLIXNOIR'), findsWidgets);

    // Verify that Aetheria (the prominent hero banner movie) is referenced
    expect(find.text('AETHERIA'), findsWidgets);

    // Verify the presence of the main navigation categories or headers
    expect(find.text('Popular'), findsWidgets);
    expect(find.text('Recently Added'), findsWidgets);
  });
}
