import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../../core/error/exceptions.dart';
import '../models/banner_model.dart';
import '../models/home_feed_item_model.dart';
import '../models/home_page_data_model.dart';

abstract class HomeRemoteDataSource {
  /// 调用 API 获取首页数据
  ///
  /// 返回 [HomePageDataModel] 包含轮播图、分类和首屏信息流数据
  /// 抛出 [ServerException] 表示服务器错误
  Future<HomePageDataModel> getHomePageData();

  /// 调用 API 获取信息流分页数据
  ///
  /// [page] 页码，从1开始
  /// [limit] 每页数量
  ///
  /// 返回 [List<HomeFeedItemModel>] 包含分页的信息流数据
  /// 抛出 [ServerException] 表示服务器错误
  Future<List<HomeFeedItemModel>> getHomeFeed(int page, int limit);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final http.Client client;

  HomeRemoteDataSourceImpl({required this.client});

  @override
  Future<HomePageDataModel> getHomePageData() async {
    // 获取轮播图数据
    final bannerResponse = await _getBanners();
    
    // 获取推荐商品列表
    final productsResponse = await _getRecommendProducts();
    
    // 构建 HomePageDataModel
    return HomePageDataModel(
      banners: bannerResponse,
      categories: [], // 目前 API 中没有分类数据，使用空列表
      feedItems: productsResponse,
    );
  }

  @override
  Future<List<HomeFeedItemModel>> getHomeFeed(int page, int limit) async {
    final url = Uri.parse('/api/shop/product/recommend/detail?code=home&page=$page&limit=$limit');
    
    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['code'] == 0 && jsonData['data'] != null) {
          final List<dynamic> productsList = jsonData['data']['products'] ?? [];
          return productsList
              .map((item) => HomeFeedItemModel.fromJson(item))
              .toList();
        } else {
          throw ServerException(message: jsonData['msg'] ?? 'Unknown error');
        }
      } else {
        throw ServerException(message: 'Failed to load home feed data');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  /// 获取轮播图数据
  Future<List<BannerModel>> _getBanners() async {
    final url = Uri.parse('/api/content/banner/list');
    final body = json.encode({
      'pageSize': 10,
      'pageNum': 1,
    });
    
    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['code'] == 0 && jsonData['data'] != null) {
          final List<dynamic> bannersList = jsonData['data']['list'] ?? [];
          return bannersList
              .map((item) => BannerModel.fromJson(item))
              .toList();
        } else {
          throw ServerException(message: jsonData['msg'] ?? 'Unknown error');
        }
      } else {
        throw ServerException(message: 'Failed to load banner data');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  /// 获取推荐商品列表
  Future<List<HomeFeedItemModel>> _getRecommendProducts() async {
    final url = Uri.parse('/api/shop/product/recommend/detail?code=home');
    
    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['code'] == 0 && jsonData['data'] != null) {
          final List<dynamic> productsList = jsonData['data']['products'] ?? [];
          return productsList
              .map((item) => HomeFeedItemModel.fromJson(item))
              .toList();
        } else {
          throw ServerException(message: jsonData['msg'] ?? 'Unknown error');
        }
      } else {
        throw ServerException(message: 'Failed to load product data');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}