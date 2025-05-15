import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// 创建一个标准化的Markdown样式表，限制标题大小
/// 确保Markdown渲染内容在视觉上与应用其他部分保持一致
class MarkdownStyleHelper {
  /// 构建适用于聊天气泡的Markdown样式表
  /// 
  /// [textColor] 基本文本颜色
  /// [context] 构建上下文，用于获取当前主题
  static MarkdownStyleSheet buildChatBubbleStyle(
    BuildContext context, 
    Color textColor,
  ) {
    final theme = Theme.of(context);
    
    return MarkdownStyleSheet(
      // 基本文本样式
      p: TextStyle(color: textColor, fontSize: 15),
      
      // 限制标题大小，确保不会过大而破坏UI
      h1: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
      h2: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
      h3: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
      h4: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
      h5: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
      h6: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
      
      // 其他常用元素样式
      em: TextStyle(color: textColor, fontStyle: FontStyle.italic),
      strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      
      // 块引用样式
      blockquote: TextStyle(
        color: textColor.withOpacity(0.7), 
        fontSize: 14,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.0),
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.5),
            width: 4.0,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
      
      // 代码样式
      code: TextStyle(
        color: theme.colorScheme.secondary,
        backgroundColor: theme.colorScheme.surface,
        fontSize: 14,
        fontFamily: 'monospace',
      ),
      codeblockPadding: const EdgeInsets.all(8.0),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4.0),
      ),
      
      // 列表样式
      listBullet: TextStyle(color: textColor, fontSize: 15),
      listIndent: 20.0,
      listBulletPadding: const EdgeInsets.only(right: 8.0),
      
      // 表格样式
      tableHead: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      tableBody: TextStyle(color: textColor),
      tableBorder: TableBorder.all(
        color: Colors.grey.withOpacity(0.3),
        width: 1.0,
      ),
      tableCellsPadding: const EdgeInsets.all(4.0),
      
      // 水平线样式
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1.0,
            color: Colors.grey.withOpacity(0.4),
          ),
        ),
      ),
      
      // 链接样式
      a: TextStyle(
        color: theme.colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
    );
  }
} 