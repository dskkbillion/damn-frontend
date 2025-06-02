import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 语言设置通知器
class LocaleNotifier extends StateNotifier<Locale?> {
  final SharedPreferences prefs;
  static const String _languageKey = 'app_language';
  
  LocaleNotifier(this.prefs) : super(null) {
    _loadSavedLocale();
  }
  
  // 加载保存的语言设置
  void _loadSavedLocale() {
    final String? languageCode = prefs.getString(_languageKey);
    if (languageCode != null) {
      state = Locale(languageCode);
    } else {
      state = null; // 使用系统默认设置
    }
  }
  
  // 设置新语言
  Future<void> setLocale(Locale locale) async {
    await prefs.setString(_languageKey, locale.languageCode);
    state = locale;
  }
  
  // 使用系统语言设置
  Future<void> useSystemLocale() async {
    await prefs.remove(_languageKey);
    state = null; // 使用系统默认设置
  }
}

// 语言提供者
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

// SharedPreferences提供者
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('需要在main.dart中初始化sharedPreferencesProvider');
}); 