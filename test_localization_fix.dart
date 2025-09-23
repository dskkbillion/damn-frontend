// Test to verify localization null safety fix
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart';

void main() {
  testWidgets('S null safety test', (WidgetTester tester) async {
    // Test that S.of returns null when not in context
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            // This should return null without localization delegates
            final l10n = S.maybeOf(context);
            expect(l10n, isNull);
            
            // Safe access with null-aware operator
            final title = l10n?.seller_auth_management_title ?? 'Fallback Title';
            expect(title, equals('Fallback Title'));
            
            return Text(title);
          },
        ),
      ),
    );
    
    // Verify the widget tree builds without errors
    expect(find.text('Fallback Title'), findsOneWidget);
  });
}