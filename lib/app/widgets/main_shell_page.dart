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

class _MainShellPageState extends ConsumerState<MainShellPage> {
  final Map<int, DateTime> _lastPrefetchTime = {};
  static const _prefetchDebounce = Duration(seconds: 30);

  void _onTap(BuildContext context, int index) {
    HapticUtils.lightTabFeedback();

    _prefetchAdjacentTab(index);

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
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
      body: widget.navigationShell,
      bottomNavigationBar: GlassNavigationSurface(
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconSize: 24,
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
