import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../entities/home_feed_item.dart';
import '../entities/home_page_data.dart';
import '../entities/product_detail.dart';
import '../entities/product_translation.dart';

/// 定义为 `Home` 模块获取聚合数据的数据访问接口
abstract class IHomeRepository {
  /// 获取首页所有区域的初始数据
  ///
  /// [seed] #384 随机排序种子（下拉刷新换序）
  /// 返回 [HomePageData] 包含轮播图、分类和首屏信息流数据
  /// 或者返回 [Failure] 表示获取数据失败
  Future<Either<Failure, HomePageData>> getHomePageData({int? seed});

  /// 获取信息流的分页数据
  ///
  /// [page] 页码，从1开始
  /// [limit] 每页数量
  /// [seed] #384 随机排序种子（loadMore 复用首屏 seed 保持分页稳定）
  ///
  /// 返回 [List<HomeFeedItem>] 包含分页的信息流数据
  /// 或者返回 [Failure] 表示获取数据失败
  Future<Either<Failure, List<HomeFeedItem>>> getHomeFeed(int page, int limit, {int? seed});

  /// 获取商品详情，返回 (ProductDetail, ProductTranslation?) 记录
  Future<Either<Failure, (ProductDetail, ProductTranslation?)>> getProductDetail(String productId);
  
  /// 搜索产品
  /// 
  /// [keyword] 搜索关键词
  /// [page] 页码，从1开始
  /// [pageSize] 每页数量
  /// 
  /// 返回 [List<HomeFeedItem>] 包含搜索结果
  /// 或者返回 [Failure] 表示搜索失败
  Future<Either<Failure, List<HomeFeedItem>>> searchProducts(
    String keyword, 
    {int page = 1, int pageSize = 20}
  );
}