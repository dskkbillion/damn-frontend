import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Chat页面设置管理器
/// 管理用户的震动反馈、动画效果等偏好设置
class ChatSettingsManager extends ChangeNotifier {
  static const String _keyHapticFeedbackEnabled = 'chat_haptic_feedback_enabled';
  static const String _keyAnimationEnabled = 'chat_animation_enabled';
  static const String _keyStreamingMode = 'chat_streaming_mode';
  static const String _keyVoiceButtonAnimation = 'chat_voice_button_animation';
  
  SharedPreferences? _prefs;
  
  // 设置值
  bool _hapticFeedbackEnabled = true;
  bool _animationEnabled = true;
  StreamingMode _streamingMode = StreamingMode.fadeIn;
  bool _voiceButtonAnimation = true;
  
  // 获取器
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;
  bool get animationEnabled => _animationEnabled;
  StreamingMode get streamingMode => _streamingMode;
  bool get voiceButtonAnimation => _voiceButtonAnimation;
  
  /// 单例实例
  static ChatSettingsManager? _instance;
  static ChatSettingsManager get instance {
    _instance ??= ChatSettingsManager._();
    return _instance!;
  }
  
  ChatSettingsManager._();
  
  /// 初始化设置管理器
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }
  
  /// 加载设置
  Future<void> _loadSettings() async {
    if (_prefs == null) return;
    
    _hapticFeedbackEnabled = _prefs!.getBool(_keyHapticFeedbackEnabled) ?? true;
    _animationEnabled = _prefs!.getBool(_keyAnimationEnabled) ?? true;
    _voiceButtonAnimation = _prefs!.getBool(_keyVoiceButtonAnimation) ?? true;
    
    final streamingModeIndex = _prefs!.getInt(_keyStreamingMode) ?? StreamingMode.fadeIn.index;
    _streamingMode = StreamingMode.values[streamingModeIndex.clamp(0, StreamingMode.values.length - 1)];
    
    notifyListeners();
  }
  
  /// 设置震动反馈开关
  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    if (_hapticFeedbackEnabled == enabled) return;
    
    _hapticFeedbackEnabled = enabled;
    await _prefs?.setBool(_keyHapticFeedbackEnabled, enabled);
    notifyListeners();
  }
  
  /// 设置动画效果开关
  Future<void> setAnimationEnabled(bool enabled) async {
    if (_animationEnabled == enabled) return;
    
    _animationEnabled = enabled;
    await _prefs?.setBool(_keyAnimationEnabled, enabled);
    notifyListeners();
  }
  
  /// 设置流式输出模式
  Future<void> setStreamingMode(StreamingMode mode) async {
    if (_streamingMode == mode) return;
    
    _streamingMode = mode;
    await _prefs?.setInt(_keyStreamingMode, mode.index);
    notifyListeners();
  }
  
  /// 设置语音按钮动画开关
  Future<void> setVoiceButtonAnimation(bool enabled) async {
    if (_voiceButtonAnimation == enabled) return;
    
    _voiceButtonAnimation = enabled;
    await _prefs?.setBool(_keyVoiceButtonAnimation, enabled);
    notifyListeners();
  }
  
  /// 重置所有设置为默认值
  Future<void> resetToDefaults() async {
    _hapticFeedbackEnabled = true;
    _animationEnabled = true;
    _streamingMode = StreamingMode.fadeIn;
    _voiceButtonAnimation = true;
    
    await _prefs?.setBool(_keyHapticFeedbackEnabled, true);
    await _prefs?.setBool(_keyAnimationEnabled, true);
    await _prefs?.setInt(_keyStreamingMode, StreamingMode.fadeIn.index);
    await _prefs?.setBool(_keyVoiceButtonAnimation, true);
    
    notifyListeners();
  }
}

/// 流式输出模式枚举
enum StreamingMode {
  /// 传统的逐字符显示
  character,
  /// 淡入式块显示（推荐）
  fadeIn,
  /// 直接显示完整内容
  instant,
}

extension StreamingModeExtension on StreamingMode {
  String get displayName {
    switch (this) {
      case StreamingMode.character:
        return '逐字符显示';
      case StreamingMode.fadeIn:
        return '淡入式显示';
      case StreamingMode.instant:
        return '直接显示';
    }
  }
  
  String get description {
    switch (this) {
      case StreamingMode.character:
        return '文字一个字一个字出现';
      case StreamingMode.fadeIn:
        return 'ChatGPT风格的分块淡入显示';
      case StreamingMode.instant:
        return '等待完整响应后一次性显示';
    }
  }
} 