import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart';
import '../widgets/delivery_file_viewer.dart';

/// 交付文件预览和下载功能演示页面
class DeliveryFilesDemoPage extends StatelessWidget {
  const DeliveryFilesDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    
    // 模拟交付文件数据
    final deliveryFiles = [
      {
        'url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        'name': 'design_final.pdf',
        'type': 'PDF文档',
      },
      {
        'url': 'https://picsum.photos/800/600',
        'name': 'product_image_01.jpg',
        'type': '产品图片',
      },
      {
        'url': 'https://sample-videos.com/doc/Sample-doc-file-100kb.doc',
        'name': 'requirements.docx',
        'type': 'Word文档',
      },
      {
        'url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        'name': 'invoice.pdf',
        'type': '发票',
      },
      {
        'url': 'https://picsum.photos/1024/768',
        'name': 'final_design.png',
        'type': '最终设计图',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.deliveryFiles ?? '交付文件'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明卡片
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '功能说明',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '这是交付文件预览和下载功能的演示页面。',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '支持的功能：',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    const Text('• 图片文件：点击可预览，支持缩放'),
                    const Text('• PDF文件：点击可预览，支持翻页'),
                    const Text('• 其他文档：点击可使用系统应用打开'),
                    const Text('• 所有文件：支持下载到本地，显示下载进度'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // 交付内容标题
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_download,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.sellerDeliveryContent ?? '卖家交付内容',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // 交付说明
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.description,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.deliveryDescription ?? '交付说明',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '您好，已按照需求完成了设计工作。交付内容包括：\n'
                      '1. 最终设计稿（PDF和PNG格式）\n'
                      '2. 产品效果图\n'
                      '3. 需求文档\n'
                      '4. 发票文件\n\n'
                      '如有任何问题，请随时联系我。',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 文件列表
            Text(
              '${l10n.deliveryFiles ?? '交付文件'} (${deliveryFiles.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            // 使用 DeliveryFileViewer 组件展示文件
            ...deliveryFiles.map((file) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DeliveryFileViewer(
                fileUrl: file['url']!,
                fileName: file['name']!,
                onDownloadComplete: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${file['name']} 下载完成'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            )),
            
            const SizedBox(height: 20),
            
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('批量下载功能开发中...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_for_offline),
                    label: const Text('批量下载'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('分享功能开发中...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('分享文件'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}