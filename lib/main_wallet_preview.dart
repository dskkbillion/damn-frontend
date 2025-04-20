import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/profile/presentation/pages/wallet_page.dart';
import 'app/di/injection_container.dart' as di;
import 'features/profile/injection_container.dart';
import 'features/profile/presentation/bloc/wallet_bloc.dart';
import 'features/profile/presentation/bloc/wallet_event.dart';

/// 钱包页面预览入口点
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化依赖注入
  final GetIt locator = GetIt.instance;
  await di.init(locator);
  await initProfileDependencies(locator);

  runApp(const WalletPreviewApp());
}

/// 钱包预览应用
class WalletPreviewApp extends StatelessWidget {
  const WalletPreviewApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '钱包页面预览',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => GetIt.instance<WalletBloc>(),
        child: const WalletPage(),
      ),
    );
  }
}
