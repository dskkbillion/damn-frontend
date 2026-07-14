import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../app/app_mode.dart';
import 'main_shell_page.dart';
import '../navigation/app_router_config.dart';
import '../../generated/app_localizations.dart';
import '../../core/utils/haptic_utils.dart';
import '../../core/services/profile_preloader_service.dart';
import '../../core/storage/secure_storage_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/widgets/glass_surface.dart';

/// 双模式导航 Shell，支持买家和卖家模式切换而不重新加载页面
class DualModeNavigationShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const DualModeNavigationShell({
    required this.navigationShell,
    super.key,
  });

  @override
  ConsumerState<DualModeNavigationShell> createState() =>
      _DualModeNavigationShellState();
}

class _DualModeNavigationShellState
    extends ConsumerState<DualModeNavigationShell>
    with SingleTickerProviderStateMixin {
  final Map<int, DateTime> _lastSellerPrefetchTime = {};
  static const _prefetchDebounce = Duration(seconds: 30);
  late final AnimationController _sellerPageTransitionController;
  late final Animation<double> _sellerPageFadeAnimation;
  late Animation<Offset> _sellerPageSlideAnimation;

  @override
  void initState() {
    super.initState();
    _sellerPageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1,
    );
    _sellerPageFadeAnimation = CurvedAnimation(
      parent: _sellerPageTransitionController,
      curve: Curves.easeOutCubic,
    );
    _sellerPageSlideAnimation = const AlwaysStoppedAnimation(Offset.zero);
  }

  @override
  void dispose() {
    _sellerPageTransitionController.dispose();
    super.dispose();
  }

  Future<void> _prefetchAdjacentSellerTab(int currentTab) async {
    final int? targetTab;
    switch (currentTab) {
      case 0:
        targetTab = 1;
      case 1:
        targetTab = 2;
      case 2:
        targetTab = 1;
      case 3:
        targetTab = 2;
      default:
        targetTab = null;
    }

    if (targetTab == null) return;

    final lastTime = _lastSellerPrefetchTime[targetTab];
    if (lastTime != null &&
        DateTime.now().difference(lastTime) < _prefetchDebounce) {
      return;
    }

    _lastSellerPrefetchTime[targetTab] = DateTime.now();

    try {
      final token = await GetIt.instance<ISecureStorageRepository>().getToken();
      if (token == null) return;

      final preloaderService = GetIt.instance<ProfilePreloaderService>();
      preloaderService.preloadCoreData().then((_) {
        AppLogger.d(
            '[SellerTabPrefetch] Prefetched data for seller tab $targetTab');
      }).catchError((e) {
        AppLogger.d(
            '[SellerTabPrefetch] Failed to prefetch seller tab $targetTab: $e');
      });
    } catch (e) {
      AppLogger.d('[SellerTabPrefetch] Error in prefetch: $e');
    }
  }

  // 获取买家分支数量
  int get _buyerBranchCount {
    final showDevTab = ref.watch(showDevTabProvider);
    return showDevTab ? 5 : 4; // AI, Home, Chat, Profile, (Dev)
  }

  /// 预加载指定模式的数据并触发BLoC缓存加载
  void _preloadModeData(AppMode mode) {
    try {
      final preloaderService = GetIt.instance<ProfilePreloaderService>();
      // 异步预加载，不阻塞UI
      preloaderService.preloadForMode(mode).then((_) {
        AppLogger.d(
            '[ModeSwitch] Successfully preloaded data for ${mode.name} mode');

        // 触发ProfileBloc使用缓存数据
        try {
          final profileBloc = GetIt.instance<ProfileBloc>();
          profileBloc.add(GetUserProfileCachedEvent(mode: mode));
          AppLogger.d(
              '[ModeSwitch] Triggered ProfileBloc cached load for ${mode.name}');
        } catch (e) {
          AppLogger.d('[ModeSwitch] Failed to trigger ProfileBloc: $e');
        }
      }).catchError((error) {
        AppLogger.d(
            '[ModeSwitch] Failed to preload data for ${mode.name} mode: $error');
      });
    } catch (e) {
      AppLogger.d('[ModeSwitch] Error getting ProfilePreloader service: $e');
    }
  }

  void _playSellerPageTransition({
    required bool isForward,
    required bool disableAnimations,
  }) {
    if (disableAnimations) {
      _sellerPageTransitionController.value = 1;
      return;
    }

    _sellerPageSlideAnimation = Tween<Offset>(
      begin: Offset(isForward ? 0.055 : -0.055, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(
          _sellerPageTransitionController,
        );
    _sellerPageTransitionController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(appModeProvider);

    // 监听模式切换
    ref.listen<AppMode>(appModeProvider, (previous, next) {
      if (previous != next) {
        // 预加载新模式的数据
        _preloadModeData(next);

        // 切换模式时，根据模式跳转到对应的"我的"页面
        if (next == AppMode.buyer) {
          // 跳转到买家的"我的"页面 (index 3)
          widget.navigationShell.goBranch(3);
        } else {
          // 跳转到卖家的"我的"页面
          // 计算卖家"我的"页面的索引：买家分支数 + 3
          widget.navigationShell.goBranch(_buyerBranchCount + 3);
        }
      }
    });

    // 根据当前模式直接返回对应的 Shell，不使用 IndexedStack
    if (currentMode == AppMode.buyer) {
      return MainShellPage(navigationShell: widget.navigationShell);
    } else {
      return _buildSellerShell(context);
    }
  }

  Widget _buildSellerShell(BuildContext context) {
    final wrapper = _SellerNavigationShellWrapper(
      navigationShell: widget.navigationShell,
      buyerBranchCount: _buyerBranchCount,
    );
    return Scaffold(
      extendBody: true,
      body: FadeTransition(
        opacity: Tween<double>(begin: 0.25, end: 1)
            .animate(_sellerPageFadeAnimation),
        child: SlideTransition(
          position: _sellerPageSlideAnimation,
          child: widget.navigationShell,
        ),
      ),
      bottomNavigationBar: _buildSellerBottomNavigationBar(wrapper),
    );
  }

  Widget _buildSellerBottomNavigationBar(
      _SellerNavigationShellWrapper wrapper) {
    return Consumer(
      builder: (context, ref, child) {
        final appLocalizations = AppLocalizations.of(context);

        return GlassNavigationSurface(
          child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconSize: 24,
              selectedFontSize: 0,
              unselectedFontSize: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textTertiary,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.analytics_outlined),
                  activeIcon: const Icon(Icons.analytics),
                  label: appLocalizations.nav_seller_analytics,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.inventory_2_outlined),
                  activeIcon: const Icon(Icons.inventory_2),
                  label: appLocalizations.nav_seller_products,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.chat_bubble_outline),
                  activeIcon: const Icon(Icons.chat_bubble),
                  label: appLocalizations.nav_seller_messages,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.account_circle_outlined),
                  activeIcon: const Icon(Icons.account_circle),
                  label: appLocalizations.nav_seller_profile,
                ),
              ],
              currentIndex: wrapper.currentIndex,
              onTap: (index) {
                // 当前卖家页不重复播放转场，也不重置既有页面状态。
                if (index == wrapper.currentIndex) return;

                // 添加轻微震动反馈
                HapticUtils.lightTabFeedback();
                _prefetchAdjacentSellerTab(index);
                _playSellerPageTransition(
                  isForward: index >= wrapper.currentIndex,
                  disableAnimations: MediaQuery.disableAnimationsOf(context),
                );
                wrapper.goBranch(index,
                    initialLocation: index == wrapper.currentIndex);
              },
          ),
        );
      },
    );
  }
}

/// 卖家导航 Shell 包装器，处理索引映射
class _SellerNavigationShellWrapper {
  final StatefulNavigationShell navigationShell;
  final int buyerBranchCount;

  _SellerNavigationShellWrapper({
    required this.navigationShell,
    required this.buyerBranchCount,
  });

  int get currentIndex {
    // 将全局索引转换为卖家本地索引
    final globalIndex = navigationShell.currentIndex;
    if (globalIndex >= buyerBranchCount) {
      return globalIndex - buyerBranchCount;
    }
    return 0;
  }

  void goBranch(int index, {bool initialLocation = false}) {
    // 将卖家本地索引转换为全局索引
    final globalIndex = index + buyerBranchCount;
    navigationShell.goBranch(globalIndex, initialLocation: initialLocation);
  }
}
