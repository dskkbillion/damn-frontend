import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

import '../cubit/search_cubit.dart';
import '../widgets/home_feed_list.dart';

class SearchResultsPage extends StatefulWidget {
  final String keyword;

  const SearchResultsPage({Key? key, required this.keyword}) : super(key: key);

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) {
        final cubit = GetIt.I<SearchCubit>();
        // 延迟执行搜索，避免在构建过程中立即触发
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            cubit.searchProducts(widget.keyword);
          }
        });
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundCard,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: GestureDetector(
            onTap: () => context.push('/home/search'),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
              decoration: BoxDecoration(
                color: AppColors.borderPrimary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.textTertiary),
                  const SizedBox(width: AppDimensions.spacingSm),
                  Expanded(
                    child: Text(
                      widget.keyword,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            if (state is SearchLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SearchError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(appLocalizations.search_failed(state.message)),
                    const SizedBox(height: AppDimensions.spacingLg),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SearchCubit>().searchProducts(widget.keyword);
                      },
                      child: Text(appLocalizations.home_retry),
                    ),
                  ],
                ),
              );
            } else if (state is SearchLoaded) {
              if (state.products.isEmpty) {
                return Center(
                  child: Text(
                    appLocalizations.search_no_results,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                );
              }

              // 复用主页的瀑布流组件
              return HomeFeedList(
                feedItems: state.products,
                isLoadingMore: state.isLoadingMore,
                hasMore: state.hasMore,
                onProductCardClicked: (product) {
                  // 跳转到商品详情页
                  context.push('/home/product/${product.id}');
                },
                onLoadMore: () {
                  if (!state.isLoadingMore && state.hasMore) {
                    context.read<SearchCubit>().loadMoreProducts(widget.keyword);
                  }
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
