import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Step 1.4 验证：Navigator.push 迁移到 GoRouter 审计
///
/// 规则：
/// - 已有 GoRouter 路由的页面：使用 context.push<bool>() 替代 Navigator.push
/// - 尚未注册路由的页面：保留 Navigator.push 并标记 TODO(Step1.4) 注释
///
/// 此测试通过静态分析源码确保每个 Navigator.push 要么已迁移，要么有 TODO 标记。
void main() {
  /// 从文件内容中提取所有非注释行中的 Navigator.push( 出现位置
  List<String> findUnmarkedNavigatorPush(String content) {
    final lines = content.split('\n');
    final unmarked = <String>[];
    for (var i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();
      // 跳过注释行
      if (trimmed.startsWith('//')) continue;
      if (trimmed.contains('Navigator.push(')) {
        // 检查前 5 行内是否有 TODO(Step1.4) 标记
        var hasTodo = false;
        for (var j = 1; j <= 5 && i - j >= 0; j++) {
          if (lines[i - j].contains('TODO(Step1.4)')) {
            hasTodo = true;
            break;
          }
        }
        if (!hasTodo) {
          unmarked.add('line ${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    return unmarked;
  }

  group('Step 1.4: Navigator.push → GoRouter 迁移审计', () {
    test('account_security_page.dart: _navigateToChangeContact 已迁移到 context.push<bool>()', () {
      final file = File('lib/features/profile/presentation/pages/account_security_page.dart');
      final content = file.readAsStringSync();

      // 验证 _navigateToChangeContact 使用 context.push<bool>
      expect(
        content.contains("context.push<bool>(\n      Uri(\n        path: '/profile/change-contact'") ||
        content.contains("context.push<bool>(") && content.contains('/profile/change-contact'),
        isTrue,
        reason: '_navigateToChangeContact should use context.push<bool> with /profile/change-contact',
      );

      // 验证没有 Navigator.push 用于 ChangeContactPage
      expect(
        content.contains('ChangeContactPage('),
        isFalse,
        reason: 'ChangeContactPage should no longer be instantiated directly (now handled by GoRouter)',
      );
    });

    test('account_security_page.dart: _navigateToUnbindContact 已迁移到 context.push<bool>()', () {
      final file = File('lib/features/profile/presentation/pages/account_security_page.dart');
      final content = file.readAsStringSync();

      // 验证 _navigateToUnbindContact 使用 context.push<bool>
      expect(
        content.contains("context.push<bool>(") && content.contains('/profile/unbind-contact'),
        isTrue,
        reason: '_navigateToUnbindContact should use context.push<bool> with /profile/unbind-contact',
      );

      // 验证没有 Navigator.push 用于 UnbindContactPage
      expect(
        content.contains('UnbindContactPage('),
        isFalse,
        reason: 'UnbindContactPage should no longer be instantiated directly (now handled by GoRouter)',
      );
    });

    test('account_security_page.dart: 未迁移的 Navigator.push 均有 TODO(Step1.4) 标记', () {
      final file = File('lib/features/profile/presentation/pages/account_security_page.dart');
      final content = file.readAsStringSync();
      final unmarked = findUnmarkedNavigatorPush(content);
      expect(
        unmarked,
        isEmpty,
        reason: 'Found Navigator.push without TODO(Step1.4) marker:\n${unmarked.join('\n')}',
      );
    });

    test('chat_page.dart: Navigator.push 已标记 TODO(Step1.4)', () {
      final file = File('lib/features/ai_docs/presentation/pages/chat_page.dart');
      final content = file.readAsStringSync();
      final unmarked = findUnmarkedNavigatorPush(content);
      expect(
        unmarked,
        isEmpty,
        reason: 'Found Navigator.push without TODO(Step1.4) marker:\n${unmarked.join('\n')}',
      );
    });

    test('account_security_page.dart: EditNicknamePage Navigator.push 有 TODO(Step1.4) 标记', () {
      final file = File('lib/features/profile/presentation/pages/account_security_page.dart');
      final content = file.readAsStringSync();

      // 验证 EditNicknamePage 仍然通过 Navigator.push（未迁移）
      expect(
        content.contains('EditNicknamePage('),
        isTrue,
        reason: 'EditNicknamePage should still exist (not yet registered in GoRouter)',
      );

      // 验证对应的 TODO 标记存在
      expect(
        content.contains('TODO(Step1.4)') && content.contains('EditNicknamePage'),
        isTrue,
        reason: 'EditNicknamePage Navigator.push should have TODO(Step1.4) marker',
      );
    });

    test('account_security_page.dart: BindContactPage Navigator.push 有 TODO(Step1.4) 标记', () {
      final file = File('lib/features/profile/presentation/pages/account_security_page.dart');
      final content = file.readAsStringSync();

      // 验证 BindContactPage 仍然通过 Navigator.push（未迁移）
      expect(
        content.contains('BindContactPage('),
        isTrue,
        reason: 'BindContactPage should still exist (needs BlocProvider, not yet registered in GoRouter)',
      );

      // 验证对应的 TODO 标记存在
      expect(
        content.contains('TODO(Step1.4)') && content.contains('BindContactPage'),
        isTrue,
        reason: 'BindContactPage Navigator.push should have TODO(Step1.4) marker',
      );
    });

    test('chat_page.dart: ChatRoomPage Navigator.push 有 TODO(Step1.4) 标记', () {
      final file = File('lib/features/ai_docs/presentation/pages/chat_page.dart');
      final content = file.readAsStringSync();

      expect(
        content.contains('TODO(Step1.4)'),
        isTrue,
        reason: 'ChatRoomPage Navigator.push should have TODO(Step1.4) marker',
      );
    });

    /// 汇总：记录已迁移和待迁移的数量
    test('迁移汇总：2 处已迁移，3 处待迁移（有 TODO 标记）', () {
      final accountSecurityContent = File(
        'lib/features/profile/presentation/pages/account_security_page.dart',
      ).readAsStringSync();
      final chatPageContent = File(
        'lib/features/ai_docs/presentation/pages/chat_page.dart',
      ).readAsStringSync();

      // 已迁移：changeContact + unbindContact
      final migratedCount =
          (accountSecurityContent.contains("context.push<bool>(") &&
                  accountSecurityContent.contains('/profile/change-contact')
              ? 1
              : 0) +
              (accountSecurityContent.contains("context.push<bool>(") &&
                      accountSecurityContent.contains('/profile/unbind-contact')
                  ? 1
                  : 0);

      // 待迁移（有 TODO）
      final todoCountInAccountSecurity =
          RegExp(r'TODO\(Step1\.4\)').allMatches(accountSecurityContent).length;
      final todoCountInChatPage =
          RegExp(r'TODO\(Step1\.4\)').allMatches(chatPageContent).length;
      final todoTotal = todoCountInAccountSecurity + todoCountInChatPage;

      expect(migratedCount, equals(2),
          reason: 'Expected 2 migrated Navigator.push calls, got $migratedCount');
      expect(todoTotal, greaterThanOrEqualTo(3),
          reason: 'Expected at least 3 TODO(Step1.4) markers across files, got $todoTotal');
    });
  });
}
