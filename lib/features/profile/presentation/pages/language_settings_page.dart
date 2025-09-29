import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dskk_flutter_refactor/core/config/locale_provider.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入生成的国际化类

class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final S s = S.of(context); // 使用S.of(context)获取当前语言的字符串
    
    return Scaffold(
      appBar: AppBar(
        title: Text(s.language_settings),
      ),
      body: ListView(
        children: [
          // 跟随系统设置
          RadioListTile<String?>(
            title: Text(s.system_language),
            subtitle: Text(s.system_language_description),
            value: null,
            groupValue: currentLocale?.languageCode,
            onChanged: (_) => ref.read(localeProvider.notifier).useSystemLocale(),
          ),
          const Divider(),
          
          // 中文选项
          RadioListTile<String>(
            title: const Text('简体中文'),
            value: 'zh',
            groupValue: currentLocale?.languageCode,
            onChanged: (value) => 
                ref.read(localeProvider.notifier).setLocale(Locale(value!)),
          ),
          
          // 英文选项
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: currentLocale?.languageCode,
            onChanged: (value) => 
                ref.read(localeProvider.notifier).setLocale(Locale(value!)),
          ),
        ],
      ),
    );
  }
} 