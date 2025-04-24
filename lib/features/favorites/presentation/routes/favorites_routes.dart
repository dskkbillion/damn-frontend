import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/favorites_bloc.dart';
import '../pages/favorites_page.dart';

/// 收藏模块路由
class FavoritesRoutes {
  /// 私有构造函数，防止实例化
  FavoritesRoutes._();

  /// 通过静态 getter 暴露路由列表
  static List<RouteBase> get routes => _routes;

  /// 模块内部路由定义
  static final List<RouteBase> _routes = [
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => BlocProvider(
        create: (context) => GetIt.instance<FavoritesBloc>(),
        child: const FavoritesPage(),
      ),
    ),
  ];
}