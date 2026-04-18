import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

import 'package:http/http.dart' as http;

import '../../../../../core/error/exceptions.dart';
import '../models/banner_model.dart';
import '../models/home_feed_item_model.dart';
import '../models/home_page_data_model.dart';
import '../models/product_detail_model.dart';
import '../../domain/entities/product_translation.dart';

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
  
  /// 从推荐系统获取推荐产品
  /// 
  /// [limit] 请求的数量
  /// 
  /// 返回 [List<HomeFeedItemModel>] 包含推荐产品
  /// 抛出 [ServerException] 表示获取推荐失败
  Future<List<HomeFeedItemModel>> getRecommendedProducts(int limit);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String modelBaseUrl; // 添加MODEL_BASE_URL
  final Future<String> Function() getToken; // 获取认证令牌的函数
  final Future<String> Function() getUserId; // 获取用户ID的函数
  final Future<String> Function() getCommonUserId; // 获取common_user_id的函数

  HomeRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.modelBaseUrl, // 注入MODEL_BASE_URL
    required this.getToken,
    required this.getUserId,
    required this.getCommonUserId, // 注入获取common_user_id的方法
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
      'Accept-Language': PlatformDispatcher.instance.locale.languageCode,
    };
  }

  @override
  Future<HomePageDataModel> getHomePageData() async {
    // 获取轮播图数据
    final bannerResponse = await _getBanners();

    // 首页首屏和后续分页统一走同一套商品列表接口，避免出现“加载更多重复”的体感。
    var productsResponse = await getHomeFeed(1, 10);

    // 商品列表为空时，再退回到推荐接口，保留新用户兜底体验。
    if (productsResponse.isEmpty) {
      productsResponse = await _getRecommendProducts();
    }
    
    // 构建 HomePageDataModel
    return HomePageDataModel(
      banners: bannerResponse,
      categories: [], // 目前 API 中没有分类数据，使用空列表
      feedItems: productsResponse,
    );
  }

  @override
  Future<List<HomeFeedItemModel>> getHomeFeed(int page, int limit) async {
    final url = Uri.parse('$baseUrl/api/shop/product/list');

    try {
      final headers = await _getHeaders();
      final response = await client.post(
        url,
        headers: headers,
        body: json.encode({
          'statusAudit': 'SUCCESS',
          'pageNum': page,
          'pageSize': limit,
        }),
      );

      AppLogger.d('首页商品列表API请求URL: $url');
      AppLogger.d('首页商品列表API请求页码: page=$page, limit=$limit');
      AppLogger.d('首页商品列表API响应状态码: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final jsonData = json.decode(responseBody);
        if (jsonData['code'] == 200 && jsonData['rows'] is List) {
          final List<dynamic> productList = jsonData['rows'] as List<dynamic>;
          return productList
              .whereType<Map<String, dynamic>>()
              .map(HomeFeedItemModel.fromJson)
              .toList();
        }
        throw ServerException(message: jsonData['msg'] ?? '首页商品列表加载失败');
      }

      throw ServerException(message: 'Failed to load home feed');
    } catch (e) {
      AppLogger.d('获取首页分页商品出错: $e');
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
      AppLogger.d('商品详情API请求URL: $url');
      AppLogger.d('商品详情API请求头: $headers');
      
      final response = await client.get(
        url,
        headers: headers,
      );

      AppLogger.d('商品详情API响应状态码: ${response.statusCode}');
      AppLogger.d('商品详情API响应内容: ${response.body}');

      if (response.statusCode == 200) {
        // 确保使用UTF-8解码
        final responseBody = utf8.decode(response.bodyBytes);
        final jsonData = json.decode(responseBody);
        if (jsonData['code'] == 200 && jsonData['data'] != null) {
          final data = jsonData['data'];
          AppLogger.d('商品详情数据: $data');

          // 解析顶层翻译数据（_translations 和 _translationMeta 与 code/data 同级）
          ProductTranslation? translation;
          final translationsMap = jsonData['_translations'];
          final translationMeta = jsonData['_translationMeta'];
          if (translationsMap is Map<String, dynamic>) {
            translation = ProductTranslation(
              translatedName: translationsMap['name'] as String?,
              translatedDescription: translationsMap['description'] as String?,
              sourceLang: translationMeta is Map<String, dynamic>
                  ? translationMeta['sourceLang'] as String?
                  : null,
              targetLang: translationMeta is Map<String, dynamic>
                  ? translationMeta['targetLang'] as String?
                  : null,
              provider: translationMeta is Map<String, dynamic>
                  ? translationMeta['provider'] as String?
                  : null,
            );
            AppLogger.d('商品详情翻译数据: $translation');
          }

          final productDetail = ProductDetailModel.fromJson(data).copyWith(
            translation: translation,
          );
          AppLogger.d('解析后的商品详情: $productDetail');

          return productDetail;
        } else {
          throw ServerException(message: jsonData['msg'] ?? 'Unknown error');
        }
      } else {
        throw ServerException(message: 'Failed to load product details');
      }
    } catch (e) {
      AppLogger.d('获取商品详情出错: $e');
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
      AppLogger.d('Banner API请求URL: $url');
      AppLogger.d('Banner API请求头: $headers');
      
      final response = await client.post(
        url,
        headers: headers,
        body: json.encode({
          "pageSize": 10,
          "pageNum": 1
        }),
      );

      AppLogger.d('Banner API响应状态码: ${response.statusCode}');
      AppLogger.d('Banner API响应内容: ${response.body}');

      if (response.statusCode == 200) {
        // 确保使用UTF-8解码
        final responseBody = utf8.decode(response.bodyBytes);
        final jsonData = json.decode(responseBody);
        if (jsonData['code'] == 200) {
          final List<dynamic> bannersList = jsonData['rows'] ?? [];
          AppLogger.d('Banner列表: $bannersList');
          
          final banners = bannersList
              .map((item) => BannerModel.fromJson(item))
              .toList();
          
          AppLogger.d('解析后的Banner列表: $banners');
          AppLogger.d('Banner图片URL: ${banners.map((b) => b.imageUrl).toList()}');
          
          return banners;
        } else {
          AppLogger.d('Banner API返回信息: ${jsonData['msg']}');
          return [];
        }
      } else {
        AppLogger.d('Banner API请求失败: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      AppLogger.d('获取轮播图出错: $e');
      return [];
    }
  }

  /// 获取推荐商品列表
  Future<List<HomeFeedItemModel>> _getRecommendProducts() async {
    return getRecommendedProducts(10);  // 获取第一页，10条数据
  }
  
  /// 从推荐系统获取推荐产品
  @override
  Future<List<HomeFeedItemModel>> getRecommendedProducts(int limit) async {
    try {
      // 修复Issue #172: 传递userId(member.id)而不是commonUserId
      // 因为Product.tenant_id对应的是Member.id
      final userId = await getUserId();
      final url = Uri.parse('$modelBaseUrl/recsys/conversation/recommend');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': await getToken(),
      };

      final body = json.encode({
        'user_id': int.tryParse(userId) ?? 1,
        'limit': limit,
      });

      AppLogger.d('推荐系统API请求URL: $url');
      AppLogger.d('推荐系统API请求体: $body');

      // 添加超时设置，防止长时间等待
      final response = await client.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          throw ServerException(message: '推荐系统请求超时');
        },
      );

      AppLogger.d('推荐系统API响应状态码: ${response.statusCode}');

      if (response.statusCode == 200) {
        // 确保使用UTF-8解码
        final responseBody = utf8.decode(response.bodyBytes);
        final jsonData = json.decode(responseBody);
        AppLogger.d('推荐系统API响应内容: $jsonData');

        if (jsonData['code'] == 200 && jsonData['data'] != null && jsonData['data']['items'] != null) {
          final items = jsonData['data']['items'] as List<dynamic>;

          // 如果推荐系统返回空数组，返回空列表而不是抛出异常
          if (items.isEmpty) {
            AppLogger.d('推荐系统返回空数据，这是新用户的正常情况');
            return [];
          }

          return items.map((item) => HomeFeedItemModel.fromJson(item)).toList();
        } else {
          AppLogger.d('推荐系统返回异常: ${jsonData['message']}');
          // 返回空列表而不是抛出异常，让用户看到空状态而不是错误
          return [];
        }
      } else {
        AppLogger.d('推荐系统API响应错误: ${response.statusCode}');
        // 返回空列表，不抛出异常
        return [];
      }
    } catch (e) {
      AppLogger.d('获取推荐产品出错: $e');
      // 出错时返回空列表，让用户可以手动刷新
      return [];
    }
  }

  @override
  Future<List<HomeFeedItemModel>> searchProducts(
    String keyword, 
    {int page = 1, int pageSize = 20}
  ) async {
    final url = Uri.parse('$baseUrl/api/shop/product/list');
    
    try {
      final headers = await _getHeaders();
      AppLogger.d('搜索API请求URL: $url');
      
      final body = json.encode({
        'keyword': keyword,
        'statusAudit': 'SUCCESS',
        'pageNum': page,
        'pageSize': pageSize,
      });
      
      AppLogger.d('搜索API请求体: $body');
      
      final response = await client.post(
        url,
        headers: headers,
        body: body,
      );

      AppLogger.d('搜索API响应状态码: ${response.statusCode}');
      AppLogger.d('搜索API响应内容: ${response.body}');

      if (response.statusCode == 200) {
        // 确保使用UTF-8解码
        final responseBody = utf8.decode(response.bodyBytes);
        final jsonData = json.decode(responseBody);
        if (jsonData['code'] == 200 && jsonData['rows'] != null) {
          final List<dynamic> productsList = jsonData['rows'] ?? [];
          AppLogger.d('搜索结果列表: $productsList');
          
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
      AppLogger.d('搜索产品出错: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}
