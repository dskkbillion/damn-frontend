import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

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
    super.key,
    required this.banners,
    this.onBannerClicked,
    this.height = 200.0,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
  });

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
    print('BannerCarousel.build: banners=${widget.banners}');
    print('BannerCarousel.build: banners.length=${widget.banners.length}');
    if (widget.banners.isNotEmpty) {
      print('BannerCarousel.build: first banner imageUrl=${widget.banners.first.imageUrl}');
    }
    
    if (widget.banners.isEmpty) {
      print('BannerCarousel.build: banners is empty');
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
                    child: Builder(
                      builder: (context) {
                        // 使用真实的图片URL
                        if (banner.imageUrl.isNotEmpty) {
                          return CachedNetworkImage(
                            imageUrl: banner.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.grey[400],
                                      size: 50,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      AppLocalizations.of(context).home_image_load_failed,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          // 如果没有图片URL，显示占位图
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    color: Colors.grey[400],
                                    size: 50,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    AppLocalizations.of(context).home_banner_placeholder(index + 1),
                                    style: TextStyle(
                                      color: Colors.grey[600],
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