# DSKK Flutter 多语言国际化解决方案

## 概述

本文档描述了DSKK Flutter项目中实现的多语言支持策略。该方案基于Flutter官方的国际化框架，支持中文和英文两种语言，并可根据用户设置或系统设置自动切换。

## 技术实现

### 核心组件

1. **Flutter Intl**：Flutter官方的国际化工具，用于生成本地化资源类
2. **ARB文件**：存储不同语言文本的资源文件
3. **Riverpod状态管理**：管理语言选择状态
4. **SharedPreferences**：持久化语言选择

### 文件结构

```
lib/
├── l10n/                      # 国际化资源目录
│   ├── intl_zh.arb            # 中文文本资源（基础/模板）
│   └── intl_en.arb            # 英文文本资源
├── generated/                 # 自动生成的代码
│   ├── l10n.dart              # 生成的国际化类
│   └── intl/                  # 生成的语言特定代码
│       ├── messages_all.dart
│       ├── messages_zh.dart
│       └── messages_en.dart
├── core/
│   └── config/
│       └── locale_provider.dart   # 语言状态管理
└── features/
    └── profile/
        └── presentation/
            └── pages/
                └── language_settings_page.dart  # 语言设置页面
```

### 配置文件

项目根目录下的`l10n.yaml`：

```yaml
arb-dir: lib/l10n
template-arb-file: intl_zh.arb
output-localization-file: app_localizations.dart
```

## 实现步骤

### 1. 基础设置

1. 添加必要依赖：

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  intl_utils: ^x.x.x
```

2. 配置`flutter`部分支持国际化：

```yaml
flutter:
  generate: true
```

### 2. 创建ARB文件

在`lib/l10n`目录中创建两个基础ARB文件：

- **intl_zh.arb**：中文资源文件，作为模板
- **intl_en.arb**：英文资源文件

ARB文件格式示例：

```json
// intl_zh.arb
{
  "@@locale": "zh",
  
  "language_settings": "语言设置",
  "system_language": "跟随系统",
  "system_language_description": "自动使用设备的语言设置",
  
  "ai_docs_assistant_title": "AI 助手",
  "ai_docs_unnamed_conversation": "未命名会话"
}

// intl_en.arb
{
  "@@locale": "en",
  
  "language_settings": "Language Settings",
  "system_language": "System Language",
  "system_language_description": "Automatically use device language settings",
  
  "ai_docs_assistant_title": "AI Assistant",
  "ai_docs_unnamed_conversation": "Unnamed Conversation"
}
```

### 3. 语言状态管理

创建`lib/core/config/locale_provider.dart`用于管理语言状态：

```dart
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
```

### 4. 应用配置

在`app.dart`中配置应用以支持国际化：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dskk_flutter_refactor/core/config/locale_provider.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart';

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      // ... 其他配置 ...
      
      // 添加国际化配置
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'), // 中文
        Locale('en'), // 英文
      ],
      locale: locale, // 用户设置的语言
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (locale != null) {
          return locale; // 如果用户设置了语言，使用用户设置
        }
        // 否则尝试使用设备语言，如不支持则使用中文
        if (deviceLocale != null) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == deviceLocale.languageCode) {
              return deviceLocale;
            }
          }
        }
        return const Locale('zh'); // 默认使用中文
      },
    );
  }
}
```

### 5. 初始化SharedPreferences

在`main.dart`中初始化SharedPreferences：

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        // 覆盖sharedPreferencesProvider
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}
```

### 6. 语言设置页面

创建语言设置页面：

```dart
class LanguageSettingsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final s = S.of(context);
    
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
```

### 7. 添加路由

在路由配置中添加语言设置页面：

```dart
GoRoute(
  path: '/profile/language-settings',
  builder: (context, state) => const LanguageSettingsPage(),
),
```

## 使用方法

### 1. 生成国际化资源

```bash
flutter gen-l10n
```

### 2. 在代码中使用国际化文本

```dart
// 获取国际化资源
final s = S.of(context);

// 使用国际化文本
Text(s.ai_docs_assistant_title)
```

### 3. 添加新文本

1. 在`intl_zh.arb`和`intl_en.arb`中添加新的文本条目
2. 运行`flutter gen-l10n`重新生成资源类
3. 在代码中使用新添加的文本

## 模块国际化示例

我们已经对AI Docs模块进行了国际化处理，主要文件有：

1. `lib/features/ai_docs/presentation/pages/chat_page.dart`
2. `lib/features/ai_docs/presentation/widgets/chat_message_list.dart`
3. `lib/features/ai_docs/presentation/widgets/chat_input_field.dart`

这些文件已从硬编码中文转换为使用国际化资源。

## 最佳实践

1. **使用前缀组织文本**：以模块名称作为前缀，如`ai_docs_assistant_title`
2. **添加参数描述**：对于有参数的文本，在ARB文件中添加详细描述
3. **分模块处理**：逐个模块进行国际化，确保完整测试
4. **命名规范**：使用一致的命名规范，如`feature_component_action`

## 未来扩展

1. **添加更多语言**：框架已支持添加更多语言，只需创建对应ARB文件
2. **自动化工具**：可考虑使用更多自动化工具进行文本提取
3. **多语言测试**：添加专门的多语言测试，确保UI适配不同语言长度

## 常见问题处理

1. **文本未正确翻译**：检查对应语言ARB文件中是否有该文本
2. **应用未跟随系统语言**：检查LocaleResolutionCallback实现
3. **生成代码出错**：删除生成的代码，重新运行`flutter gen-l10n`

## 参考资料

- [Flutter国际化文档](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
- [Flutter Intl插件](https://marketplace.visualstudio.com/items?itemName=localizely.flutter-intl)
- [Intl Utils包](https://pub.dev/packages/intl_utils) 