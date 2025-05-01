import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../entities/home_feed_item.dart';
import '../entities/home_page_data.dart';

/// 定义为 `Home` 模块获取聚合数据的数据访问接口
abstract class IHomeRepository {
  /// 获取首页所有区域的初始数据
  /// 
  /// 返回 [HomePageData] 包含轮播图、分类和首屏信息流数据
  /// 或者返回 [Failure] 表示获取数据失败
  Future<Either<Failure, HomePageData>> getHomePageData();

  /// 获取信息流的分页数据
  /// 
  /// [page] 页码，从1开始
  /// [limit] 每页数量
  /// 
  /// 返回 [List<HomeFeedItem>] 包含分页的信息流数据
  /// 或者返回 [Failure] 表示获取数据失败
  Future<Either<Failure, List<HomeFeedItem>>> getHomeFeed(int page, int limit);
}