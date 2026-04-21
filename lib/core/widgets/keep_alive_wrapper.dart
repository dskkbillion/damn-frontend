import 'package:flutter/material.dart';

/// 保持页面状态的包装器
/// 
/// 使用 AutomaticKeepAliveClientMixin 来保持页面状态
/// 避免页面在切换时重新构建
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  final bool keepAlive;
  
  const KeepAliveWrapper({
    super.key,
    required this.child,
    this.keepAlive = true,
  });
  
  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
  
  @override
  bool get wantKeepAlive => widget.keepAlive;
}