import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

/// 聊天测试入口页面
/// 用于快速测试新旧聊天实现
class ChatTestEntry extends StatelessWidget {
  const ChatTestEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天测试入口'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppColors.primaryWithOpacity05,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '聊天重构测试',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '新版本使用 flutter_chat_ui 组件库',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '特性：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('• 离线消息支持'),
                    Text('• WebSocket自动重连'),
                    Text('• 性能优化'),
                    Text('• 消息缓存'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // 测试聊天室列表
            const Text(
              '选择测试聊天室:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // 测试聊天室1 - 客服
            _buildChatTestItem(
              context: context,
              title: '客服聊天',
              subtitle: '测试与客服的对话',
              chatId: 'service_chat_001',
              isNew: true,
            ),
            
            const SizedBox(height: 10),
            
            // 测试聊天室2 - 买家
            _buildChatTestItem(
              context: context,
              title: '买家聊天',
              subtitle: '测试买家购买商品的对话',
              chatId: 'buyer_chat_001',
              isNew: true,
            ),
            
            const SizedBox(height: 10),
            
            // 测试聊天室3 - 卖家
            _buildChatTestItem(
              context: context,
              title: '卖家聊天',
              subtitle: '测试卖家售后的对话',
              chatId: 'seller_chat_001',
              isNew: true,
            ),
            
            const Divider(height: 30),
            
            const Text(
              '对比测试（旧版本）:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // 旧版本测试
            _buildChatTestItem(
              context: context,
              title: '旧版聊天',
              subtitle: '使用原始实现',
              chatId: 'test_chat_001',
              isNew: false,
            ),
            
            const Spacer(),
            
            // 测试说明
            Card(
              color: AppColors.warning.withValues(alpha: 0.1),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '测试步骤：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('1. 点击进入聊天室'),
                    Text('2. 发送文本消息'),
                    Text('3. 发送图片/音频'),
                    Text('4. 测试断网重连'),
                    Text('5. 测试消息撤回'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTestItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String chatId,
    required bool isNew,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isNew ? AppColors.success : AppColors.textTertiary,
          child: const Icon(
            Icons.chat,
            color: AppColors.onPrimary,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Chip(
          label: Text(isNew ? '新版' : '旧版'),
          backgroundColor: isNew ? AppColors.success : AppColors.backgroundSecondary,
        ),
        onTap: () {
          // 导航到聊天页面
          final route = isNew 
              ? '/chat/refactored/$chatId'
              : '/chat/$chatId';
          
          context.push(route);
        },
      ),
    );
  }
}