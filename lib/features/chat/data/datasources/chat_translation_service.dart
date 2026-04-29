import 'dart:ui';
import 'package:dskk_flutter_refactor/core/network/core_dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 聊天消息翻译服务
/// 调用后端 /api/translation/translate-text 接口
class ChatTranslationService {
  final CoreDioClient _coreDioClient;

  // 本地内存缓存：cacheKey -> translatedText
  final Map<int, String> _cache = {};

  ChatTranslationService(this._coreDioClient);

  /// 翻译消息
  /// [messageId] 消息ID
  /// [text] 原文
  /// [targetLang] 目标语言代码（如 "en", "zh", "ja"）
  Future<String?> translateMessage(
      int messageId, String text, String targetLang) async {
    // 1. 先查本地缓存
    final cacheKey = _buildCacheKey(messageId, targetLang);
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    // 2. 调后端 translate-text 接口
    try {
      final response = await _coreDioClient.post(
        '/api/translation/translate-text',
        data: {
          'text': text,
          'targetLang': targetLang,
          'messageId': messageId,
        },
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['code'] == 200) {
        final translated = response.data['data'] as String?;
        if (translated != null && translated.isNotEmpty) {
          _cache[cacheKey] = translated;
          return translated;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取用户当前语言的 DeepL 语言代码
  static Future<String> getTargetLang() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString('app_language');
      if (savedLang != null && savedLang.isNotEmpty) {
        return _toDeepLLangCode(savedLang);
      }
    } catch (_) {}

    // fallback 到系统语言
    final locale = PlatformDispatcher.instance.locale;
    return _toDeepLLangCode(locale.languageCode);
  }

  static String _toDeepLLangCode(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'zh':
        return 'zh';
      case 'en':
        return 'en';
      case 'ja':
        return 'ja';
      case 'ko':
        return 'ko';
      case 'vi':
        return 'vi';
      default:
        return 'en';
    }
  }

  /// 清除缓存
  void clearCache() => _cache.clear();

  int _buildCacheKey(int messageId, String targetLang) {
    return '$messageId:$targetLang'.hashCode;
  }
}
