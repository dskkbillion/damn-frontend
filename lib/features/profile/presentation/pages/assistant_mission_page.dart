import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// 小帮手的使命页面
class AssistantMissionPage extends StatelessWidget {
  const AssistantMissionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.profile_assistant_mission),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题区域
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.smart_toy_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '小帮手的使命',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 使命宣言
            _buildSection(
              context,
              title: '我们的使命',
              content: '连接创意与需求，让每一个想法都能找到实现的可能。小帮手致力于为用户提供最贴心、最智能的服务体验，成为您生活和工作中最可靠的数字伙伴。',
              icon: Icons.flag_outlined,
            ),
            
            const SizedBox(height: 24),
            
            // 核心价值
            _buildSection(
              context,
              title: '核心价值',
              content: '• 用户至上：始终以用户需求为出发点\n• 创新驱动：持续探索新技术和新方法\n• 诚信服务：提供可靠、透明的服务体验\n• 共同成长：与用户和合作伙伴携手前行',
              icon: Icons.favorite_outlined,
            ),
            
            const SizedBox(height: 24),
            
            // 服务承诺
            _buildSection(
              context,
              title: '服务承诺',
              content: '我们承诺为每一位用户提供：\n\n✓ 7×24小时智能服务支持\n✓ 个性化的解决方案推荐\n✓ 安全可靠的数据保护\n✓ 持续优化的用户体验\n✓ 及时响应的客户服务',
              icon: Icons.handshake_outlined,
            ),
            
            const SizedBox(height: 24),
            
            // 未来愿景
            _buildSection(
              context,
              title: '未来愿景',
              content: '成为全球领先的智能服务平台，通过AI技术赋能，让每个人都能享受到个性化、高效率的数字化生活体验。我们相信，科技的力量应该让生活更美好，让创意更容易实现。',
              icon: Icons.rocket_launch_outlined,
            ),
            
            const SizedBox(height: 32),
            
            // 联系我们
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '有问题或建议？',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '我们随时倾听您的声音，期待与您一起创造更美好的未来。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: 添加联系我们功能
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('联系功能即将上线，敬请期待！')),
                      );
                    },
                    icon: const Icon(Icons.message_outlined),
                    label: const Text('联系我们'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
} 