import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 应用模式枚举
enum AppMode { buyer, seller }

/// 全局应用模式状态提供者
final appModeProvider = StateProvider<AppMode>((ref) => AppMode.buyer); // 默认买家模式 