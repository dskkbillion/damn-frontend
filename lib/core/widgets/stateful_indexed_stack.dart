import 'package:flutter/material.dart';

/// 有状态的 IndexedStack，保持所有子页面的状态
/// 即使在切换时也不会重建
class StatefulIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final bool preloadAll;
  
  const StatefulIndexedStack({
    Key? key,
    required this.index,
    required this.children,
    this.preloadAll = false,
  }) : super(key: key);
  
  @override
  State<StatefulIndexedStack> createState() => _StatefulIndexedStackState();
}

class _StatefulIndexedStackState extends State<StatefulIndexedStack> {
  final List<bool> _loaded = [];
  
  @override
  void initState() {
    super.initState();
    _loaded.addAll(List.filled(widget.children.length, false));
    
    if (widget.preloadAll) {
      // 预加载所有页面
      for (int i = 0; i < _loaded.length; i++) {
        _loaded[i] = true;
      }
    } else {
      // 只加载当前页面
      _loaded[widget.index] = true;
    }
  }
  
  @override
  void didUpdateWidget(StatefulIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 确保新索引的页面已加载
    if (widget.index < _loaded.length) {
      _loaded[widget.index] = true;
    }
    
    // 如果子组件数量变化，更新加载状态
    if (widget.children.length != oldWidget.children.length) {
      if (widget.children.length > _loaded.length) {
        _loaded.addAll(List.filled(
          widget.children.length - _loaded.length,
          false,
        ));
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: List.generate(widget.children.length, (i) {
        if (!_loaded[i]) {
          // 未加载的页面显示空容器
          return const SizedBox.shrink();
        }
        
        // 使用 PageStorage 保存页面状态
        return PageStorage(
          bucket: PageStorageBucket(),
          child: widget.children[i],
        );
      }),
    );
  }
}