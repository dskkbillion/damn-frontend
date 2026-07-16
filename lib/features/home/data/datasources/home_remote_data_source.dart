import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  /// [seed] #384 随机排序种子，下拉刷新换序、分页内复用保持稳定
  /// 抛出 [ServerException] 表示服务器错误
  Future<HomePageDataModel> getHomePageData({int? seed});

  /// 调用 API 获取信息流分页数据
  ///
  /// [page] 页码，从1开始
  /// [limit] 每页数量
  /// [seed] #384 随机排序种子（可选）
  ///
  /// 返回 [List<HomeFeedItemModel>] 包含分页的信息流数据
  /// 抛出 [ServerException] 表示服务器错误
  Future<List<HomeFeedItemModel>> getHomeFeed(int page, int limit,
      {int? seed, String? feedId});

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
  Future<List<HomeFeedItemModel>> searchProducts(String keyword,
      {int page = 1, int pageSize = 20});
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
    // http 包不走全局 Dio 拦截器链，必须手动设置 Accept-Language
    final prefs = await SharedPreferences.getInstance();
    final appLanguage = prefs.getString('app_language');
    final language =
        appLanguage ?? PlatformDispatcher.instance.locale.languageCode;
    return {
      'Content-Type': 'application/json',
      'Authorization': token,
      'clienttype': '1',
      'client': 'android',
      'version': '100',
      'Accept-Language': language,
    };
  }

  @override
  Future<HomePageDataModel> getHomePageData({int? seed}) async {
    // 获取轮播图数据
    final bannerResponse = await _getBanners();

    List<HomeFeedItemModel> productsResponse;
    String? feedId;
    try {
      // 首页必须让模型端同时决定首屏与后续分页；不能首屏个性化、
      // 第二页又混进普通随机列表。
      final homeFeed = await _getHomeRecommendation(page: 1, limit: 10);
      productsResponse = homeFeed.items;
      feedId = homeFeed.feedId;
    } catch (error) {
      // 模型服务不可用时保留原商品列表作为可见的降级路径。
      AppLogger.d('首页画像推荐不可用，降级到商品列表: $error');
      productsResponse = await getHomeFeed(1, 10, seed: seed);
    }

    // 构建 HomePageDataModel
    return HomePageDataModel(
      banners: bannerResponse,
      categories: const [], // 目前 API 中没有分类数据，使用空列表
      feedItems: productsResponse,
      feedId: feedId,
    );
  }

  @override
  Future<List<HomeFeedItemModel>> getHomeFeed(int page, int limit,
      {int? seed, String? feedId}) async {
    if (feedId != null && feedId.isNotEmpty) {
      return (await _getHomeRecommendation(
              page: page, limit: limit, feedId: feedId))
          .items;
    }
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
          // #384 随机排序种子，非空时后端 ORDER BY top DESC, RAND(seed)
          if (seed != null) 'seed': seed,
        }),
      );

      AppLogger.d('首页商品列表API请求URL: $url');
      AppLogger.d('首页商品列表API请求页码: page=$page, limit=$limit, seed=$seed');
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

  Future<_HomeRecommendationPage> _getHomeRecommendation({
    required int page,
    required int limit,
    String? feedId,
  }) async {
    final userId = int.tryParse(await getUserId());
    if (userId == null || userId <= 0) {
      throw ServerException(message: '未登录，无法构建首页兴趣画像');
    }
    final url = Uri.parse('$modelBaseUrl/recsys/home/feed');
    final response = await client
        .post(
          url,
          headers: await _getHeaders(),
          body: json.encode({
            'user_id': userId,
            'page': page,
            'limit': limit,
            if (feedId != null) 'feed_id': feedId,
          }),
        )
        .timeout(
          const Duration(seconds: 8),
          onTimeout: () => throw ServerException(message: '首页推荐系统请求超时'),
        );
    final body = utf8.decode(response.bodyBytes);
    final jsonData = json.decode(body);
    final data = jsonData is Map<String, dynamic> ? jsonData['data'] : null;
    if (response.statusCode != 200 ||
        jsonData['code'] != 200 ||
        data is! Map<String, dynamic>) {
      final message = jsonData is Map<String, dynamic>
          ? (jsonData['msg'] ?? '首页推荐服务不可用').toString()
          : '首页推荐服务不可用';
      throw ServerException(message: message);
    }
    final rawItems = data['items'];
    if (rawItems is! List || data['feed_id'] is! String) {
      throw ServerException(message: '首页推荐响应格式错误');
    }
    AppLogger.d(
        '首页画像推荐: strategy=${data['strategy']}, page=$page, feedId=${data['feed_id']}');
    return _HomeRecommendationPage(
      feedId: data['feed_id'] as String,
      hasMore: data['has_more'] == true,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(HomeFeedItemModel.fromJson)
          .toList(),
    );
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
        body: json.encode({"pageSize": 10, "pageNum": 1}),
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

          final banners =
              bannersList.map((item) => BannerModel.fromJson(item)).toList();

          AppLogger.d('解析后的Banner列表: $banners');
          AppLogger.d(
              'Banner图片URL: ${banners.map((b) => b.imageUrl).toList()}');

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

  @override
  Future<List<HomeFeedItemModel>> searchProducts(String keyword,
      {int page = 1, int pageSize = 20}) async {
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
              translatedName: item['translatedName'] as String?,
              translatedDescription: item['translatedDescription'] as String?,
              translationSourceLang: item['translationSourceLang'] as String?,
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

class _HomeRecommendationPage {
  final String feedId;
  final bool hasMore;
  final List<HomeFeedItemModel> items;

  const _HomeRecommendationPage({
    required this.feedId,
    required this.hasMore,
    required this.items,
  });
}
