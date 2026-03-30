import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/shimmer_effect.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/skeleton_list_item.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/skeleton_card.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/skeleton_chat_item.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/skeleton_page.dart';

void main() {
  group('Skeleton widgets', () {
    testWidgets('ShimmerEffect renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerEffect(
              child: SizedBox(width: 100, height: 20),
            ),
          ),
        ),
      );
      expect(find.byType(ShimmerEffect), findsOneWidget);
    });

    testWidgets('SkeletonListItem renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonListItem(),
          ),
        ),
      );
      expect(find.byType(SkeletonListItem), findsOneWidget);
    });

    testWidgets('SkeletonCard renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );
      expect(find.byType(SkeletonCard), findsOneWidget);
    });

    testWidgets('SkeletonChatItem renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonChatItem(),
          ),
        ),
      );
      expect(find.byType(SkeletonChatItem), findsOneWidget);
    });

    testWidgets('SkeletonPage renders 3 skeleton items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonPage(itemCount: 3),
          ),
        ),
      );
      expect(find.byType(SkeletonListItem), findsNWidgets(3));
    });
  });
}
