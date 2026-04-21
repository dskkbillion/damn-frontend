import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_mode.dart';

/// 保持模式切换时页面状态的 Shell 包装器
class ModePreservedShell extends ConsumerStatefulWidget {
  final Widget buyerShell;
  final Widget sellerShell;
  
  const ModePreservedShell({
    super.key,
    required this.buyerShell,
    required this.sellerShell,
  });
  
  @override
  ConsumerState<ModePreservedShell> createState() => _ModePreservedShellState();
}

class _ModePreservedShellState extends ConsumerState<ModePreservedShell> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentMode = ref.watch(appModeProvider);
    
    // 使用 IndexedStack 来保持两个 Shell 的状态
    // 切换模式时不会销毁页面
    return IndexedStack(
      index: currentMode == AppMode.buyer ? 0 : 1,
      children: [
        // 买家 Shell - 保持状态
        KeepAlive(
          keepAlive: true,
          child: widget.buyerShell,
        ),
        // 卖家 Shell - 保持状态
        KeepAlive(
          keepAlive: true,
          child: widget.sellerShell,
        ),
      ],
    );
  }
}

/// 包装子组件以保持其状态
class KeepAlive extends StatefulWidget {
  final Widget child;
  final bool keepAlive;
  
  const KeepAlive({
    super.key,
    required this.child,
    this.keepAlive = true,
  });
  
  @override
  State<KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<KeepAlive> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => widget.keepAlive;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}