import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_mode.dart';
import '../../app/widgets/main_shell_page.dart';
import '../../core/widgets/keep_alive_wrapper.dart';
import '../../features/seller/presentation/widgets/seller_shell_page.dart';

/// 双模式Shell包装器，用于在买家和卖家模式之间切换时保持页面状态
class DualModeShellWrapper extends ConsumerStatefulWidget {
  final Widget Function(BuildContext, GoRouterState, StatefulNavigationShell) buyerBuilder;
  final Widget Function(BuildContext, GoRouterState, StatefulNavigationShell) sellerBuilder;
  final StatefulNavigationShell navigationShell;
  final GoRouterState state;
  
  const DualModeShellWrapper({
    super.key,
    required this.buyerBuilder,
    required this.sellerBuilder,
    required this.navigationShell,
    required this.state,
  });
  
  @override
  ConsumerState<DualModeShellWrapper> createState() => _DualModeShellWrapperState();
}

class _DualModeShellWrapperState extends ConsumerState<DualModeShellWrapper> 
    with TickerProviderStateMixin {
  late PageController _pageController;
  Widget? _buyerShell;
  Widget? _sellerShell;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(appModeProvider) == AppMode.buyer ? 0 : 1,
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(appModeProvider);
    
    // 创建或更新买家Shell
    _buyerShell ??= widget.buyerBuilder(context, widget.state, widget.navigationShell);
    
    // 创建或更新卖家Shell
    _sellerShell ??= widget.sellerBuilder(context, widget.state, widget.navigationShell);
    
    // 监听模式变化，切换页面
    ref.listen<AppMode>(appModeProvider, (previous, next) {
      if (previous != next) {
        _pageController.animateToPage(
          next == AppMode.buyer ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(), // 禁止手势滑动
      children: [
        // 买家模式页面
        KeepAliveWrapper(
          child: _buyerShell!,
        ),
        // 卖家模式页面  
        KeepAliveWrapper(
          child: _sellerShell!,
        ),
      ],
    );
  }
}

/// 模式感知的Shell路由构建器
class ModeAwareShellRoute extends StatefulShellRoute {
  ModeAwareShellRoute({
    required List<StatefulShellBranch> buyerBranches,
    required List<StatefulShellBranch> sellerBranches,
    super.parentNavigatorKey,
    super.restorationScopeId,
  }) : super.indexedStack(
    builder: (context, state, navigationShell) {
      return Consumer(
        builder: (context, ref, child) {
          final currentMode = ref.watch(appModeProvider);
          
          // 根据当前模式返回对应的Shell
          if (currentMode == AppMode.buyer) {
            return MainShellPage(navigationShell: navigationShell);
          } else {
            return SellerShellPage(navigationShell: navigationShell);
          }
        },
      );
    },
    branches: [
      ...buyerBranches,
      ...sellerBranches,
    ],
  );
}