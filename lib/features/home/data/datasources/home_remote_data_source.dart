import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../../core/error/exceptions.dart';
import '../models/banner_model.dart';
import '../models/home_feed_item_model.dart';
import '../models/home_page_data_model.dart';
import '../models/product_detail_model.dart';

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

  /// 获取商品详情
  ///
  /// [productId] 商品ID
  ///
  /// 返回 [ProductDetailModel] 包含商品详细信息
  /// 抛出 [ServerException] 表示服务器错误
  Future<ProductDetailModel> getProductDetail(String productId);
  
  /// 搜索产品
  /// 
  /// [keyword] 搜索关键词
  /// [page] 页码，从1开始
  /// [pageSize] 每页数量
  /// 
  /// 返回 [List<HomeFeedItemModel>] 包含搜索结果
  /// 抛出 [ServerException] 表示搜索失败
  Future<List<HomeFeedItemModel>> searchProducts(
    String keyword, 
    {int page = 1, int pageSize = 20}
  );
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final Future<String> Function() getToken; // 获取认证令牌的函数
  final Future<String> Function() getUserId; // 获取用户ID的函数

  HomeRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.getToken,
    required this.getUserId,
  });

  /// 获取请求头
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': token,
      'clienttype': '1',
      'client': 'android',
      'version': '100',
    };
  }

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
    final url = Uri.parse('$baseUrl/api/shop/product/recommend/detail?code=home&page=$page&limit=$limit');
    
    try {
      final headers = await _getHeaders();
      print('Feed API请求URL: $url');
      print('Feed API请求头: $headers');
      
      final response = await client.get(
        url,
        headers: headers,
      );

      print('Feed API响应状态码: ${response.statusCode}');
      print('Feed API响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['code'] == 200 && jsonData['data'] != null) {
          final List<dynamic> productsList = jsonData['data']['products'] ?? [];
          print('产品列表: $productsList');
          
          final products = productsList
              .map((item) => HomeFeedItemModel.fromJson(item))
              .toList();
          
          print('解析后的产品列表: $products');
          print('产品图片URL: ${products.map((p) => p.images).toList()}');
          
          return products;
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

  @override
  Future<ProductDetailModel> getProductDetail(String productId) async {
    final url = Uri.parse('$baseUrl/api/shop/product/get?id=$productId');
    
    try {
      final headers = await _getHeaders();
      print('商品详情API请求URL: $url');
      print('商品详情API请求头: $headers');
      
      final response = await client.get(
        url,
        headers: headers,
      );

      print('商品详情API响应状态码: ${response.statusCode}');
      print('商品详情API响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['code'] == 200 && jsonData['data'] != null) {
          final data = jsonData['data'];
          print('商品详情数据: $data');
          
          final productDetail = ProductDetailModel.fromJson(data);
          print('解析后的商品详情: $productDetail');
          
          return productDetail;
        } else {
          throw ServerException(message: jsonData['msg'] ?? 'Unknown error');
        }
      } else {
        throw ServerException(message: 'Failed to load product details');
      }
    } catch (e) {
      print('获取商品详情出错: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  /// 获取轮播图数据
  Future<List<BannerModel>> _getBanners() async {
    final url = Uri.parse('$baseUrl/api/content/banner/list');
    
    try {
      final headers = await _getHeaders();
      print('Banner API请求URL: $url');
      print('Banner API请求头: $headers');
      
      final response = await client.post(
        url,
        headers: headers,
        body: json.encode({
          "pageSize": 10,
          "pageNum": 1
        }),
      );

      print('Banner API响应状态码: ${response.statusCode}');
      print('Banner API响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['code'] == 200) {
          final List<dynamic> bannersList = jsonData['rows'] ?? [];
          print('Banner列表: $bannersList');
          
          final banners = bannersList
              .map((item) => BannerModel.fromJson(item))
              .toList();
          
          print('解析后的Banner列表: $banners');
          print('Banner图片URL: ${banners.map((b) => b.imageUrl).toList()}');
          
          return banners;
        } else {
          print('Banner API返回信息: ${jsonData['msg']}');
          return [];
        }
      } else {
        print('Banner API请求失败: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('获取轮播图出错: $e');
      return [];
    }
  }

  /// 获取推荐商品列表
  Future<List<HomeFeedItemModel>> _getRecommendProducts() async {
    return getHomeFeed(1, 10);  // 获取第一页，每页10条数据
  }

  @override
  Future<List<HomeFeedItemModel>> searchProducts(
    String keyword, 
    {int page = 1, int pageSize = 20}
  ) async {
    final url = Uri.parse('$baseUrl/api/shop/product/list');
    
    try {
      final headers = await _getHeaders();
      print('搜索API请求URL: $url');
      
      final body = json.encode({
        'keyword': keyword,
        'statusAudit': 'SUCCESS',
        'pageNum': page,
        'pageSize': pageSize,
      });
      
      print('搜索API请求体: $body');
      
      final response = await client.post(
        url,
        headers: headers,
        body: body,
      );

      print('搜索API响应状态码: ${response.statusCode}');
      print('搜索API响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['code'] == 200 && jsonData['rows'] != null) {
          final List<dynamic> productsList = jsonData['rows'] ?? [];
          print('搜索结果列表: $productsList');
          
          final List<HomeFeedItemModel> products = [];
          
          for (var item in productsList) {
            // 处理图片URL - 尤其是JSON字符串格式的图片
            List<String> processImages(dynamic images) {
              List<String> result = [];
              if (images == null) return result;
              
              if (images is List) {
                for (var img in images) {
                  if (img is String) {
                    if (img.startsWith('[') && img.endsWith(']')) {
                      try {
                        // 尝试解析JSON字符串
                        final parsed = jsonDecode(img);
                        if (parsed is List && parsed.isNotEmpty) {
                          result.add(parsed[0].toString());
                        } else {
                          result.add(img);
                        }
                      } catch (_) {
                        result.add(img);
                      }
                    } else {
                      result.add(img);
                    }
                  }
                }
              }
              return result;
            }
            
            final String id = (item['id'] ?? 0).toString();
            final String name = item['name'] ?? '';
            final String description = item['description'] ?? '';
            final List<String> images = processImages(item['images']);
            final double sellingPrice = item['sellingPrice'] is String
                ? double.tryParse(item['sellingPrice']) ?? 0.0
                : (item['sellingPrice'] ?? 0.0);
            final String? score = item['score'];
            final int evaluateNum = item['evaluateNum'] ?? 0;
            
            products.add(HomeFeedItemModel(
              id: id,
              type: 'product', // 默认类型为产品
              name: name,
              images: images,
              sellingPrice: sellingPrice,
              score: double.tryParse(score ?? '5.0') ?? 5.0,
              evaluateNum: evaluateNum,
            ));
          }
          
          return products;
        } else {
          throw ServerException(message: jsonData['msg'] ?? 'Unknown error');
        }
      } else {
        throw ServerException(message: 'Failed to search products');
      }
    } catch (e) {
      print('搜索产品出错: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}