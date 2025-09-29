import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dskk_flutter_refactor/app/app.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化依赖注入
  await InjectionContainer.init();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}