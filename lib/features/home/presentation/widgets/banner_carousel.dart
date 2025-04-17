import 'dart:async';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
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
      if (_currentIndex < widget.banners.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.jumpToPage(0);
      }
    });
  }

  void _stopAutoPlay() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
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
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      banner.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // 简单的页面指示器
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }
}