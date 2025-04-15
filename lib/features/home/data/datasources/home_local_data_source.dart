import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/error/exceptions.dart';
import '../models/home_feed_item_model.dart';
import '../models/home_page_data_model.dart';

abstract class HomeLocalDataSource {
  /// 获取缓存的首页数据
  ///
  /// 返回 [HomePageDataModel] 包含轮播图、分类和首屏信息流数据
  /// 抛出 [CacheException] 表示缓存不存在或无效
  Future<HomePageDataModel> getLastHomePageData();

  /// 缓存首页数据
  ///
  /// [homePageData] 要缓存的首页数据
  Future<void> cacheHomePageData(HomePageDataModel homePageData);

  /// 获取缓存的信息流分页数据
  ///
  /// [page] 页码，从1开始
  ///
  /// 返回 [List<HomeFeedItemModel>] 包含分页的信息流数据
  /// 抛出 [CacheException] 表示缓存不存在或无效
  Future<List<HomeFeedItemModel>> getLastHomeFeed(int page);

  /// 缓存信息流分页数据
  ///
  /// [page] 页码，从1开始
  /// [homeFeed] 要缓存的信息流数据
  Future<void> cacheHomeFeed(int page, List<HomeFeedItemModel> homeFeed);
}

const CACHED_HOME_PAGE_DATA = 'CACHED_HOME_PAGE_DATA';
const CACHED_HOME_FEED_PREFIX = 'CACHED_HOME_FEED_PAGE_';

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final SharedPreferences sharedPreferences;

  HomeLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<HomePageDataModel> getLastHomePageData() {
    final jsonString = sharedPreferences.getString(CACHED_HOME_PAGE_DATA);
    if (jsonString != null) {
      try {
        return Future.value(
          HomePageDataModel.fromJson(json.decode(jsonString)),
        );
      } catch (e) {
        throw CacheException();
      }
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheHomePageData(HomePageDataModel homePageData) {
    return sharedPreferences.setString(
      CACHED_HOME_PAGE_DATA,
      json.encode(homePageData.toJson()),
    );
  }

  @override
  Future<List<HomeFeedItemModel>> getLastHomeFeed(int page) {
    final jsonString = sharedPreferences.getString('$CACHED_HOME_FEED_PREFIX$page');
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        return Future.value(
          jsonList.map((item) => HomeFeedItemModel.fromJson(item)).toList(),
        );
      } catch (e) {
        throw CacheException();
      }
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheHomeFeed(int page, List<HomeFeedItemModel> homeFeed) {
    final jsonList = homeFeed.map((item) => (item as HomeFeedItemModel).toJson()).toList();
    return sharedPreferences.setString(
      '$CACHED_HOME_FEED_PREFIX$page',
      json.encode(jsonList),
    );
  }
}