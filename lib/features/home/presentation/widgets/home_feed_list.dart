import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../domain/entities/home_feed_item.dart';
import 'product_card.dart';

/// 信息流列表组件
class HomeFeedList extends StatefulWidget {
  /// 信息流列表
  final List<HomeFeedItem> feedItems;
  
  /// 商品/服务卡片点击回调
  final Function(HomeFeedItem item)? onProductCardClicked;
  
  /// "让ta看看"按钮点击回调
  final Function(HomeFeedItem item)? onRecommendClicked;
  
  /// 加载更多回调
  final VoidCallback? onLoadMore;
  
  /// 是否正在加载更多
  final bool isLoadingMore;
  
  /// 是否有更多数据
  final bool hasMore;
  
  /// 每行显示的卡片数量
  final int crossAxisCount;
  
  /// 卡片之间的间距
  final double spacing;
  
  /// 行之间的间距
  final double runSpacing;
  
  /// 是否显示"让ta看看"按钮
  final bool showRecommendButton;

  const HomeFeedList({
    Key? key,
    required this.feedItems,
    this.onProductCardClicked,
    this.onRecommendClicked,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.crossAxisCount = 2,
    this.spacing = 10.0,
    this.runSpacing = 16.0,
    this.showRecommendButton = false, // 默认不显示"让ta看看"按钮
  }) : super(key: key);

  @override
  State<HomeFeedList> createState() => _HomeFeedListState();
}

class _HomeFeedListState extends State<HomeFeedList> {
  final ScrollController _scrollController = ScrollController();
  bool _reachedBottomOnce = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !_reachedBottomOnce) {
      setState(() {
        _reachedBottomOnce = true;
      });
    }

    if (_isBottom && widget.hasMore && !widget.isLoadingMore && widget.onLoadMore != null) {
      widget.onLoadMore!();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // 当滚动到距离底部 200 像素时触发加载更多
    return currentScroll >= (maxScroll - 200);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.feedItems.isEmpty) {
      return const Center(
        child: Text('暂无数据'),
      );
    }

    // 使用 MasonryGridView 实现瀑布流布局
    return Column(
      children: [
        Expanded(
          child: MasonryGridView.count(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            crossAxisCount: widget.crossAxisCount,
            mainAxisSpacing: widget.runSpacing,
            crossAxisSpacing: widget.spacing,
            itemCount: widget.feedItems.length,
            itemBuilder: (context, index) {
              final item = widget.feedItems[index];
              // 根据索引生成不同的宽高比，使瀑布流更自然
              final aspectRatio = 0.8 + (index % 3) * 0.2;
              
              return ProductCard(
                item: item,
                aspectRatio: aspectRatio,
                onCardClicked: () {
                  if (widget.onProductCardClicked != null) {
                    widget.onProductCardClicked!(item);
                  }
                },
                onRecommendClicked: () {
                  if (widget.onRecommendClicked != null) {
                    widget.onRecommendClicked!(item);
                  }
                },
                showRecommendButton: widget.showRecommendButton, // 传递显示设置
              );
            },
          ),
        ),
        if (widget.isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        if (!widget.hasMore && _reachedBottomOnce)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '已经到底了',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
}
