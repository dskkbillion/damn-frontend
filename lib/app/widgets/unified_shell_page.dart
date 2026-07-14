import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/app_mode.dart';
import '../../generated/app_localizations.dart';
import '../../core/utils/haptic_utils.dart';
import '../navigation/app_router_config.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/widgets/glass_surface.dart';

/// 统一的 Shell 页面，支持买家和卖家模式切换而不重新加载页面
class UnifiedShellPage extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const UnifiedShellPage({
    required this.navigationShell,
    super.key,
  });

  @override
  ConsumerState<UnifiedShellPage> createState() => _UnifiedShellPageState();
}

class _UnifiedShellPageState extends ConsumerState<UnifiedShellPage>
    with TickerProviderStateMixin {
  // 保存每个模式的导航索引
  int _buyerIndex = 0; // 默认 AI 助手
  int _sellerIndex = 0; // 默认数据页
  late final AnimationController _pageTransitionController;
  late Animation<Offset> _pageSlideAnimation;
  late final Animation<double> _pageFadeAnimation;

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

  // 获取买家模式的分支索引范围
  List<int> get _buyerBranches {
    final showDevTab = ref.watch(showDevTabProvider);
    return showDevTab ? [0, 1, 2, 3, 4] : [0, 1, 2, 3];
  }

  // 获取卖家模式的分支索引范围
  List<int> get _sellerBranches {
    final buyerBranchCount = _buyerBranches.length;
    return [
      buyerBranchCount, // 卖家数据
      buyerBranchCount + 1, // 商品管理
      buyerBranchCount + 2, // 卖家消息
      buyerBranchCount + 3, // 卖家我的
    ];
  }

  void _onTap(int index) {
    HapticUtils.lightTabFeedback();

    final mode = ref.read(appModeProvider);
    final previousIndex = mode == AppMode.buyer ? _buyerIndex : _sellerIndex;
    final actualIndex =
        mode == AppMode.buyer ? _buyerBranches[index] : _sellerBranches[index];

    // 更新对应模式的索引
    if (mode == AppMode.buyer) {
      _buyerIndex = index;
    } else {
      _sellerIndex = index;
    }

    _playPageTransition(
      isForward: index >= previousIndex,
      disableAnimations: MediaQuery.disableAnimationsOf(context),
    );

    widget.navigationShell.goBranch(
      actualIndex,
      initialLocation: actualIndex == widget.navigationShell.currentIndex,
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

    // 让一级页面切换有明确的方向感；导航栏保持静止，避免干扰点击。
    final horizontalOffset = isForward ? 0.055 : -0.055;
    _pageSlideAnimation = Tween<Offset>(
      begin: Offset(horizontalOffset, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(
          _pageTransitionController,
        );
    _pageTransitionController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appModeProvider);
    final appLocalizations = AppLocalizations.of(context);

    // 监听模式切换，切换到对应的分支
    ref.listen<AppMode>(appModeProvider, (previous, next) {
      if (previous != next) {
        // 切换到对应模式的最后访问的分支
        final targetIndex = next == AppMode.buyer
            ? _buyerBranches[_buyerIndex]
            : _sellerBranches[_sellerIndex];

        _playPageTransition(
          isForward: true,
          disableAnimations: MediaQuery.disableAnimationsOf(context),
        );
        widget.navigationShell.goBranch(targetIndex);
      }
    });

    return Scaffold(
      extendBody: true,
      body: FadeTransition(
        opacity: Tween<double>(begin: 0.25, end: 1).animate(_pageFadeAnimation),
        child: SlideTransition(
          position: _pageSlideAnimation,
          child: widget.navigationShell,
        ),
      ),
      bottomNavigationBar: GlassNavigationSurface(
        child: mode == AppMode.buyer
            ? _buildBuyerNavigationBar(context, appLocalizations)
            : _buildSellerNavigationBar(appLocalizations),
      ),
    );
  }

  Widget _buildBuyerNavigationBar(
      BuildContext context, AppLocalizations appLocalizations) {
    final showDevTab = ref.watch(showDevTabProvider);

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

    return BottomNavigationBar(
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
      currentIndex: _buyerIndex,
      onTap: _onTap,
    );
  }

  Widget _buildSellerNavigationBar(AppLocalizations appLocalizations) {
    // 为卖家模式创建自定义的导航栏

    return BottomNavigationBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconSize: 24,
      selectedFontSize: 0,
      unselectedFontSize: 0,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
            icon: const Icon(Icons.analytics_outlined),
            activeIcon: const Icon(Icons.analytics),
            label: appLocalizations.nav_seller_analytics),
        BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_outlined),
            activeIcon: const Icon(Icons.inventory_2),
            label: appLocalizations.nav_seller_products),
        BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            activeIcon: const Icon(Icons.chat_bubble),
            label: appLocalizations.nav_seller_messages),
        BottomNavigationBarItem(
            icon: const Icon(Icons.account_circle_outlined),
            activeIcon: const Icon(Icons.account_circle),
            label: appLocalizations.nav_seller_profile),
      ],
      currentIndex: _sellerIndex,
      onTap: _onTap,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    );
  }
}
