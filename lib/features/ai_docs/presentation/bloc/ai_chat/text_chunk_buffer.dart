import 'dart:async';
import 'package:flutter/services.dart';
import '../../settings/chat_settings_manager.dart';

/// 文本分块缓冲器
/// 用于实现ChatGPT风格的"淡出式"流式输出效果
class TextChunkBuffer {
  final StringBuffer _buffer = StringBuffer();
  static const Duration _flushInterval = Duration(milliseconds: 300);
  final int _minChunkSize = 8; // 最小分块大小
  Timer? _flushTimer;
  bool _isDisposed = false;
  
  /// 回调函数，当有新的文本块准备好时触发
  final void Function(String chunk, bool isComplete) onChunkReady;
  
  TextChunkBuffer({
    required this.onChunkReady,
  });
  
  /// 添加新的文本块
  void addChunk(String chunk) {
    if (chunk.isEmpty || _isDisposed) return;
    
    _buffer.write(chunk);
    
    // 重置定时器
    _flushTimer?.cancel();
    _flushTimer = Timer(_flushInterval, () {
      if (!_isDisposed) {
        _flushBuffer(isComplete: false);
      }
    });
    
    // 检查是否应该立即flush
    if (_shouldFlushImmediately()) {
      _flushBuffer(isComplete: false);
    }
  }
  
  /// 完成输入，flush所有剩余内容
  void complete() {
    if (_isDisposed) return;
    _flushTimer?.cancel();
    if (_buffer.isNotEmpty) {
      _flushBuffer(isComplete: true);
    }
  }
  
  /// 检查是否应该立即flush
  bool _shouldFlushImmediately() {
    final currentText = _buffer.toString();
    
    // 如果达到最小块大小且遇到标点符号，立即flush
    if (currentText.length >= _minChunkSize) {
      // 检查是否以标点符号结尾
      if (RegExp(r'[。！？.,!?;；：:\n]$').hasMatch(currentText)) {
        return true;
      }
      
      // 检查是否包含换行符
      if (currentText.contains('\n')) {
        return true;
      }
      
      // 如果达到较大长度，也flush
      if (currentText.length >= 20) {
        return true;
      }
    }
    
    return false;
  }
  
  /// 将缓冲区内容输出并清空
  void _flushBuffer({required bool isComplete}) {
    if (_buffer.isEmpty || _isDisposed) return;
    
    final text = _buffer.toString();
    _buffer.clear();
    
    // 触发震动反馈
    if (ChatSettingsManager.instance.hapticFeedbackEnabled && text.isNotEmpty) {
      HapticFeedback.selectionClick();
    }
    
    // 调用回调函数
    onChunkReady(text, isComplete);
  }
  
  /// 清理资源
  void dispose() {
    _isDisposed = true;
    _flushTimer?.cancel();
    _buffer.clear();
  }
}

/// 文本块实体
class TextChunk {
  final String content;
  final DateTime timestamp;
  final bool isComplete;
  final String id;
  
  TextChunk({
    required this.content,
    required this.timestamp,
    required this.isComplete,
    required this.id,
  });
  
  @override
  String toString() {
    return 'TextChunk(content: "$content", isComplete: $isComplete, id: $id)';
  }
}
