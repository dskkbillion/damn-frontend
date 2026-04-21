import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// 商品图片轮播组件（不使用第三方库）
class ProductImagesCarousel extends StatefulWidget {
  /// 图片URL列表
  final List<String> images;

  /// 图片点击回调
  final Function(int index)? onImageClicked;

  /// 轮播图高度
  final double height;

  /// 自动播放
  final bool autoPlay;

  /// 自动播放间隔
  final Duration autoPlayInterval;

  /// Hero tag，传入时首张图片（index==0）会包裹 Hero 动画
  final String? heroTag;

  const ProductImagesCarousel({
    super.key,
    required this.images,
    this.onImageClicked,
    this.height = 300.0,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.heroTag,
  });

  @override
  State<ProductImagesCarousel> createState() => _ProductImagesCarouselState();
}

class _ProductImagesCarouselState extends State<ProductImagesCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay && widget.images.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (widget.images.isEmpty) return;

      if (_pageController.hasClients) {
        if (_currentIndex < widget.images.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _stopAutoPlay() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                color: AppColors.textTertiary,
                size: 50,
              ),
              SizedBox(height: AppDimensions.spacingMd),
              Text(
                '暂无图片',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = widget.images[index];
              return GestureDetector(
                onTap: () {
                  if (widget.onImageClicked != null) {
                    widget.onImageClicked!(index);
                  }
                },
                child: AppNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  heroTag: index == 0 ? widget.heroTag : null,
                ),
              );
            },
          ),
        ),

        // 添加指示器（仅当有多张图片时显示）
        if (widget.images.length > 1)
          Positioned(
            bottom: AppDimensions.spacingLg,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => Container(
                  width: AppDimensions.spacingSm,
                  height: AppDimensions.spacingSm,
                  margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXs),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white.withOpacity(0.7),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.borderSecondary,
                        blurRadius: 2,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 添加计数指示器
        if (widget.images.length > 1)
          Positioned(
            bottom: AppDimensions.spacingLg,
            right: AppDimensions.spacingLg,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingSm,
                vertical: AppDimensions.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AppColors.borderSecondary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.images.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
