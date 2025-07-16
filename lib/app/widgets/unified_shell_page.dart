import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/app_mode.dart';
import '../../generated/l10n.dart';
import '../../core/utils/haptic_utils.dart';
import '../../features/seller/presentation/widgets/seller_bottom_navigation_bar.dart';
import '../navigation/app_router_config.dart';

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
  int _buyerIndex = 1; // 默认首页
  int _sellerIndex = 0; // 默认数据页
  
  // 获取当前模式下的导航索引
  int get _currentIndex {
    final mode = ref.watch(appModeProvider);
    return mode == AppMode.buyer ? _buyerIndex : _sellerIndex;
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
      buyerBranchCount,     // 卖家数据
      buyerBranchCount + 1, // 商品管理
      buyerBranchCount + 2, // 卖家消息
      buyerBranchCount + 3, // 卖家我的
    ];
  }
  
  void _onTap(int index) {
    HapticUtils.lightTabFeedback();
    
    final mode = ref.read(appModeProvider);
    final actualIndex = mode == AppMode.buyer 
        ? _buyerBranches[index]
        : _sellerBranches[index];
    
    // 更新对应模式的索引
    if (mode == AppMode.buyer) {
      _buyerIndex = index;
    } else {
      _sellerIndex = index;
    }
    
    widget.navigationShell.goBranch(
      actualIndex,
      initialLocation: actualIndex == widget.navigationShell.currentIndex,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appModeProvider);
    final s = S.of(context);
    
    // 监听模式切换，切换到对应的分支
    ref.listen<AppMode>(appModeProvider, (previous, next) {
      if (previous != next) {
        // 切换到对应模式的最后访问的分支
        final targetIndex = next == AppMode.buyer 
            ? _buyerBranches[_buyerIndex]
            : _sellerBranches[_sellerIndex];
        
        widget.navigationShell.goBranch(targetIndex);
      }
    });
    
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: mode == AppMode.buyer 
          ? _buildBuyerNavigationBar(context, s)
          : _buildSellerNavigationBar(),
    );
  }
  
  Widget _buildBuyerNavigationBar(BuildContext context, S s) {
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
          colorFilter: ColorFilter.mode(const Color(0xFFD0903D), BlendMode.srcIn),
        ),
        label: s.nav_ai_assistant,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home),
        label: s.nav_home,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.chat_bubble_outline),
        activeIcon: const Icon(Icons.chat_bubble),
        label: s.nav_messages,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline),
        activeIcon: const Icon(Icons.person),
        label: s.nav_profile,
      ),
    ];
    
    if (showDevTab) {
      items.add(BottomNavigationBarItem(
        icon: const Icon(Icons.developer_mode_outlined),
        activeIcon: const Icon(Icons.developer_mode),
        label: s.nav_dev,
      ));
    }
    
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFD0903D),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: items,
      currentIndex: _buyerIndex,
      onTap: _onTap,
    );
  }
  
  Widget _buildSellerNavigationBar() {
    // 为卖家模式创建自定义的导航栏
    final s = S.of(context);
    
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, 
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.analytics_outlined), 
          activeIcon: const Icon(Icons.analytics), 
          label: s.nav_seller_analytics
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.inventory_2_outlined), 
          activeIcon: const Icon(Icons.inventory_2), 
          label: s.nav_seller_products
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat_bubble_outline), 
          activeIcon: const Icon(Icons.chat_bubble), 
          label: s.nav_seller_messages
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.account_circle_outlined), 
          activeIcon: const Icon(Icons.account_circle), 
          label: s.nav_seller_profile
        ),
      ],
      currentIndex: _sellerIndex,
      onTap: _onTap,
      selectedItemColor: const Color(0xFFD0903D),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
    );
  }
}