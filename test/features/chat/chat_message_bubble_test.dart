import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/widgets/ai_summary_message_bubble.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ChatMessage message(String type, String context) => ChatMessage(
        id: 1,
        chatId: 2,
        senderId: 3,
        type: type,
        context: context,
        createTime: DateTime(2026, 7, 21),
        withdrawFlag: false,
      );

  test('recognizes historical Agent request text envelopes', () {
    expect(
      ChatMessageBubble.isLegacyAgentRequestMessage(
        message(
          'text',
          '[DeepStream request #7] 7 天工作节奏调整方案\n\n需求正文',
        ),
      ),
      isTrue,
    );
  });

  test('does not reclassify ordinary text or malformed request labels', () {
    expect(
      ChatMessageBubble.isLegacyAgentRequestMessage(
        message('text', '请看一下 [DeepStream request #7]'),
      ),
      isFalse,
    );
    expect(
      ChatMessageBubble.isLegacyAgentRequestMessage(
        message('text', '[DeepStream request #x] 普通文本'),
      ),
      isFalse,
    );
  });

  testWidgets('summary card shows a concise preview and structured expansion',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const summary = '''具体需求分析：
服务内容：明确询问硬件组装、系统安装和测试优化三大核心环节
服务期望：希望获得清晰易懂的装机流程说明

用户画像推测：
身份背景：可能是初次尝试装机的电脑使用者
优先关注：服务内容的专业性和流程透明度

服务建议：提供图文版装机流程指南和视频教程链接''';

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: AiSummaryMessageBubble(
              message: message('ai_summary', summary),
              sellerName: '服务方',
              isCurrentUserMessage: true,
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('硬件组装'), findsOneWidget);
    expect(find.text('用户画像推测'), findsNothing);

    await tester.tap(find.text('展开'));
    await tester.pumpAndSettle();

    expect(find.text('具体需求分析'), findsOneWidget);
    expect(find.text('用户画像推测'), findsOneWidget);
    expect(find.textContaining('服务建议'), findsOneWidget);
    expect(find.text('收起'), findsOneWidget);
  });
}
