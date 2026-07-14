import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart'; // 导入SVG插件
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/core/services/profile_preloader_service.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router_config.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源
import 'package:dskk_flutter_refactor/core/utils/haptic_utils.dart'; // 导入震动工具类
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';

class MainShellPage extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellPage({required this.navigationShell, super.key});

  @override
  ConsumerState<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends ConsumerState<MainShellPage>
    with SingleTickerProviderStateMixin {
  final Map<int, DateTime> _lastPrefetchTime = {};
  static const _prefetchDebounce = Duration(seconds: 30);
  late final AnimationController _pageTransitionController;
  late final Animation<double> _pageFadeAnimation;
  late Animation<Offset> _pageSlideAnimation;

  @override
  void initState() {
    super.initState();
    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1,
    );
    _pageFadeAnimation = CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutCubic,
    );
    _pageSlideAnimation = const AlwaysStoppedAnimation(Offset.zero);
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    super.dispose();
  }

  void _onTap(BuildContext context, int index) {
    // 当前页面不做任何导航或动画，避免重复点按时产生无意义的闪动。
    if (index == widget.navigationShell.currentIndex) return;

    HapticUtils.lightTabFeedback();

    _prefetchAdjacentTab(index);
    _playPageTransition(
      isForward: index >= widget.navigationShell.currentIndex,
      disableAnimations: MediaQuery.disableAnimationsOf(context),
    );

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _playPageTransition({
    required bool isForward,
    required bool disableAnimations,
  }) {
    if (disableAnimations) {
      _pageTransitionController.value = 1;
      return;
    }

    _pageSlideAnimation = Tween<Offset>(
      begin: Offset(isForward ? 0.055 : -0.055, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(
          _pageTransitionController,
        );
    _pageTransitionController.forward(from: 0);
  }

  Future<void> _prefetchAdjacentTab(int currentTab) async {
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

    final lastTime = _lastPrefetchTime[targetTab];
    if (lastTime != null &&
        DateTime.now().difference(lastTime) < _prefetchDebounce) {
      return;
    }

    _lastPrefetchTime[targetTab] = DateTime.now();

    try {
      final token = await GetIt.instance<ISecureStorageRepository>().getToken();
      if (token == null) return;

      final preloaderService = GetIt.instance<ProfilePreloaderService>();
      preloaderService.preloadCoreData().then((_) {
        AppLogger.d('[TabPrefetch] Prefetched data for tab $targetTab');
      }).catchError((e) {
        AppLogger.d('[TabPrefetch] Failed to prefetch tab $targetTab: $e');
      });
    } catch (e) {
      AppLogger.d('[TabPrefetch] Error in prefetch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final showDevTab = ref.watch(showDevTabProvider);
    final appLocalizations = AppLocalizations.of(context);
    final List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: SvgPicture.asset(
          'assets/icons/nav/dskk_logo.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
        ),
        activeIcon: SvgPicture.asset(
          'assets/icons/nav/dskk_logo.svg',
          width: 24,
          height: 24,
          colorFilter:
              const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
        label: appLocalizations.nav_ai_assistant,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home),
        label: appLocalizations.nav_home,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.chat_bubble_outline),
        activeIcon: const Icon(Icons.chat_bubble),
        label: appLocalizations.nav_messages,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline),
        activeIcon: const Icon(Icons.person),
        label: appLocalizations.nav_profile,
      ),
    ];

    if (showDevTab) {
      items.add(BottomNavigationBarItem(
        icon: const Icon(Icons.developer_mode_outlined),
        activeIcon: const Icon(Icons.developer_mode),
        label: appLocalizations.nav_dev,
      ));
    }

    return Scaffold(
      extendBody: true,
      // 让页面背景和滚动内容延伸到悬浮导航下方；各页面只在其可滚动
      // 内容末端预留安全距离，避免壳层裁出大块空白。
      body: FadeTransition(
        opacity: Tween<double>(begin: 0.25, end: 1).animate(_pageFadeAnimation),
        child: SlideTransition(
          position: _pageSlideAnimation,
          child: widget.navigationShell,
        ),
      ),
      bottomNavigationBar: GlassNavigationSurface(
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
            items: items,
            currentIndex: widget.navigationShell.currentIndex,
            onTap: (index) => _onTap(context, index),
        ),
      ),
    );
  }
}
