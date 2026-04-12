import 'dart:async';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

import '../../domain/entities/banner.dart' as home_banner;

/// 简化版轮播图组件（不使用第三方库）
class BannerCarousel extends StatefulWidget {
  /// 轮播图列表
  final List<home_banner.Banner> banners;

  /// 轮播图点击回调
  final Function(home_banner.Banner banner)? onBannerClicked;

  /// 轮播图高度
  final double height;

  /// 自动播放
  final bool autoPlay;

  /// 自动播放间隔
  final Duration autoPlayInterval;

  const BannerCarousel({
    Key? key,
    required this.banners,
    this.onBannerClicked,
    this.height = 200.0,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
  }) : super(key: key);

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }

      if (widget.banners.isEmpty) return;

      if (!_disposed &&
          _pageController.hasClients &&
          mounted &&
          _pageController.page != null) {
        try {
          if (_currentIndex < widget.banners.length - 1) {
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
        } catch (e) {
          debugPrint('BannerCarousel: PageController error: $e');
          timer.cancel();
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
    AppLogger.d('BannerCarousel.build: banners=${widget.banners}');
    AppLogger.d('BannerCarousel.build: banners.length=${widget.banners.length}');
    if (widget.banners.isNotEmpty) {
      AppLogger.d('BannerCarousel.build: first banner imageUrl=${widget.banners.first.imageUrl}');
    }

    if (widget.banners.isEmpty) {
      AppLogger.d('BannerCarousel.build: banners is empty');
      return SizedBox(height: widget.height);
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return GestureDetector(
                onTap: () {
                  if (widget.onBannerClicked != null) {
                    widget.onBannerClicked!(banner);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.borderSecondary,
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    child: Builder(
                      builder: (context) {
                        // 使用真实的图片URL
                        if (banner.imageUrl.isNotEmpty) {
                          return AppNetworkImage(
                            imageUrl: banner.imageUrl,
                            fit: BoxFit.cover,
                          );
                        } else {
                          // 如果没有图片URL，显示占位图
                          return Container(
                            color: AppColors.borderPrimary,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    color: AppColors.textTertiary,
                                    size: 50,
                                  ),
                                  const SizedBox(height: AppDimensions.spacingMd),
                                  Text(
                                    '轮播图 ${index + 1}',
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
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        // 简单的页面指示器
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => Container(
              width: AppDimensions.spacingSm,
              height: AppDimensions.spacingSm,
              margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXs),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.borderInput,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
