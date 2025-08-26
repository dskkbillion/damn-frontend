import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/delivery_file_viewer.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('DeliveryFileViewer', () {
    testWidgets('displays file information correctly', (WidgetTester tester) async {
      // Arrange
      const testFileUrl = 'https://example.com/test.pdf';
      const testFileName = 'test.pdf';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: DeliveryFileViewer(
              fileUrl: testFileUrl,
              fileName: testFileName,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testFileName), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });

    testWidgets('shows correct icon for different file types', (WidgetTester tester) async {
      // Test image file
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: DeliveryFileViewer(
              fileUrl: 'https://example.com/image.jpg',
              fileName: 'image.jpg',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.image), findsOneWidget);

      // Test document file
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: DeliveryFileViewer(
              fileUrl: 'https://example.com/document.docx',
              fileName: 'document.docx',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.description), findsOneWidget);
    });

    testWidgets('download button is visible when file is not downloaded', (WidgetTester tester) async {
      // Arrange
      const testFileUrl = 'https://example.com/test.pdf';
      const testFileName = 'test.pdf';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          home: Scaffold(
            body: DeliveryFileViewer(
              fileUrl: testFileUrl,
              fileName: testFileName,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.download), findsOneWidget);
    });
  });

  group('ImagePreviewPage', () {
    testWidgets('displays image URL and filename', (WidgetTester tester) async {
      // Arrange
      const testImageUrl = 'https://example.com/image.jpg';
      const testFileName = 'image.jpg';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ImagePreviewPage(
            imageUrl: testImageUrl,
            fileName: testFileName,
          ),
        ),
      );

      // Assert
      expect(find.text(testFileName), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}