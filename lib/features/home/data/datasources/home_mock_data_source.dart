import 'dart:math';

import '../../../../../core/error/exceptions.dart';
import '../../domain/entities/banner.dart' as home_banner;
import '../../domain/entities/home_category.dart';
import '../../domain/entities/home_feed_item.dart';
import '../models/banner_model.dart';
import '../models/home_category_model.dart';
import '../models/home_feed_item_model.dart';
import '../models/home_page_data_model.dart';
import 'home_remote_data_source.dart';

/// 提供 Mock 数据的数据源，用于预览和测试
class HomeMockDataSource implements HomeRemoteDataSource {
  final Random _random = Random();

  @override
  Future<HomePageDataModel> getHomePageData() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 随机决定是否抛出异常（10%的概率）
    if (_random.nextDouble() < 0.1) {
      throw ServerException(message: '模拟服务器错误');
    }
    
    return HomePageDataModel(
      banners: _getMockBanners(),
      categories: _getMockCategories(),
      feedItems: _getMockFeedItems(1, 10),
    );
  }

  @override
  Future<List<HomeFeedItemModel>> getHomeFeed(int page, int limit) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 随机决定是否抛出异常（10%的概率）
    if (_random.nextDouble() < 0.1) {
      throw ServerException(message: '模拟服务器错误');
    }
    
    // 模拟分页，第3页后没有更多数据
    if (page > 3) {
      return [];
    }
    
    return _getMockFeedItems(page, limit);
  }

  /// 获取模拟轮播图数据
  List<BannerModel> _getMockBanners() {
    return [
      const BannerModel(
        id: '1',
        imageUrl: 'https://picsum.photos/800/400?random=1',
        targetType: 'product',
        targetValue: '101',
        createTime: '2025-04-01 10:00:00',
        updateTime: '2025-04-01 10:00:00',
      ),
      const BannerModel(
        id: '2',
        imageUrl: 'https://picsum.photos/800/400?random=2',
        targetType: 'category',
        targetValue: '201',
        createTime: '2025-04-02 10:00:00',
        updateTime: '2025-04-02 10:00:00',
      ),
      const BannerModel(
        id: '3',
        imageUrl: 'https://picsum.photos/800/400?random=3',
        targetType: 'url',
        targetValue: 'https://flutter.dev',
        createTime: '2025-04-03 10:00:00',
        updateTime: '2025-04-03 10:00:00',
      ),
      const BannerModel(
        id: '4',
        imageUrl: 'https://picsum.photos/800/400?random=4',
        targetType: 'product',
        targetValue: '102',
        createTime: '2025-04-04 10:00:00',
        updateTime: '2025-04-04 10:00:00',
      ),
      const BannerModel(
        id: '5',
        imageUrl: 'https://picsum.photos/800/400?random=5',
        targetType: 'product',
        targetValue: '103',
        createTime: '2025-04-05 10:00:00',
        updateTime: '2025-04-05 10:00:00',
      ),
    ];
  }

  /// 获取模拟分类数据
  List<HomeCategoryModel> _getMockCategories() {
    return [
      const HomeCategoryModel(
        id: '1',
        name: '留学服务',
        iconUrl: 'https://picsum.photos/100/100?random=1',
        targetType: 'category',
        targetValue: '101',
      ),
      const HomeCategoryModel(
        id: '2',
        name: '搜题解答',
        iconUrl: 'https://picsum.photos/100/100?random=2',
        targetType: 'category',
        targetValue: '102',
      ),
      const HomeCategoryModel(
        id: '3',
        name: '家装设计',
        iconUrl: 'https://picsum.photos/100/100?random=3',
        targetType: 'category',
        targetValue: '103',
      ),
      const HomeCategoryModel(
        id: '4',
        name: '旅游咨询',
        iconUrl: 'https://picsum.photos/100/100?random=4',
        targetType: 'category',
        targetValue: '104',
      ),
      const HomeCategoryModel(
        id: '5',
        name: '文书润色',
        iconUrl: 'https://picsum.photos/100/100?random=5',
        targetType: 'category',
        targetValue: '105',
      ),
      const HomeCategoryModel(
        id: '6',
        name: '论文指导',
        iconUrl: 'https://picsum.photos/100/100?random=6',
        targetType: 'category',
        targetValue: '106',
      ),
      const HomeCategoryModel(
        id: '7',
        name: '简历修改',
        iconUrl: 'https://picsum.photos/100/100?random=7',
        targetType: 'category',
        targetValue: '107',
      ),
      const HomeCategoryModel(
        id: '8',
        name: '翻译服务',
        iconUrl: 'https://picsum.photos/100/100?random=8',
        targetType: 'category',
        targetValue: '108',
      ),
      const HomeCategoryModel(
        id: '9',
        name: '作业辅导',
        iconUrl: 'https://picsum.photos/100/100?random=9',
        targetType: 'category',
        targetValue: '109',
      ),
      const HomeCategoryModel(
        id: '10',
        name: '更多服务',
        iconUrl: 'https://picsum.photos/100/100?random=10',
        targetType: 'feature',
        targetValue: 'more_services',
      ),
    ];
  }

  /// 获取模拟信息流数据
  List<HomeFeedItemModel> _getMockFeedItems(int page, int limit) {
    final List<HomeFeedItemModel> items = [];
    final int startIndex = (page - 1) * limit;
    
    for (int i = 0; i < limit; i++) {
      final int itemId = startIndex + i + 1;
      items.add(HomeFeedItemModel(
        id: itemId.toString(),
        type: 'product',
        name: '模拟服务 $itemId - ${_getRandomServiceName()}',
        images: [
          'https://picsum.photos/400/300?random=$itemId',
        ],
        sellingPrice: _getRandomPrice(),
        score: _getRandomScore(),
        evaluateNum: _random.nextInt(500) + 10,
      ));
    }
    
    return items;
  }

  /// 获取随机服务名称
  String _getRandomServiceName() {
    final List<String> serviceNames = [
      '文书润色服务',
      '留学申请指导',
      '作业辅导解答',
      '论文修改服务',
      '简历优化指导',
      '翻译服务',
      '数学题解答',
      '物理题解答',
      '化学题解答',
      '编程作业辅导',
      '家装设计咨询',
      '旅游路线规划',
      '重庆旅游咨询',
      '上海旅游避雷',
      '北京旅游攻略',
      '广州美食指南',
      '深圳科技游',
      '成都美食推荐',
      '杭州西湖游览',
      '苏州园林欣赏',
    ];
    
    return serviceNames[_random.nextInt(serviceNames.length)];
  }

  /// 获取随机价格
  double _getRandomPrice() {
    // 生成 10-1000 之间的随机价格
    return (_random.nextInt(990) + 10).toDouble();
  }

  /// 获取随机评分
  double _getRandomScore() {
    // 生成 4.0-5.0 之间的随机评分，限制为1位小数
    double score = 4.0 + _random.nextDouble();
    return double.parse(score.toStringAsFixed(1)); // 转换为1位小数
  }
}