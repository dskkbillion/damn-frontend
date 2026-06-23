import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/currency/presentation/cubit/currency_cubit.dart';
import 'package:dskk_flutter_refactor/core/currency/domain/entities/currency.dart';

import 'package:dskk_flutter_refactor/core/widgets/skeleton/product_card_skeleton.dart';

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
    super.key,
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
  });

  @override
  State<HomeFeedList> createState() => _HomeFeedListState();
}

class _HomeFeedListState extends State<HomeFeedList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _prefetchCurrencyConversions();
  }

  @override
  void didUpdateWidget(covariant HomeFeedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // feedItems 变化（如加载更多）后补预折算
    if (!identical(oldWidget.feedItems, widget.feedItems)) {
      _prefetchCurrencyConversions();
    }
  }

  /// #348 性能优化：列表加载后批量预折算所有商品价格，
  /// 避免每张卡片 PriceDisplayWidget 各自自驱动触发冗余 fx 请求。
  /// widget 自驱动逻辑仍保留作兜底（增量加载/缓存 miss）。
  void _prefetchCurrencyConversions() {
    if (widget.feedItems.isEmpty) return;
    final amounts = widget.feedItems
        .map((e) => e.sellingPrice)
        .where((p) => p > 0)
        .toSet()
        .toList();
    if (amounts.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CurrencyCubit>().convertMultiplePrices(
            amounts: amounts,
            sourceCurrency: Currency.usd,
          );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
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
      return Center(
        child: Text(AppLocalizations.of(context).home_no_data),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: ProductCardSkeleton(aspectRatio: 0.8 + (widget.feedItems.length % 3) * 0.2)),
                const SizedBox(width: 10),
                Expanded(child: ProductCardSkeleton(aspectRatio: 0.8 + ((widget.feedItems.length + 1) % 3) * 0.2)),
              ],
            ),
          ),
        if (!widget.hasMore)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                AppLocalizations.of(context).home_reached_end,
                style: const TextStyle(
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