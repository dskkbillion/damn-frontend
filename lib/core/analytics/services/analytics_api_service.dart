import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import '../entities/analytics_event.dart';
import 'dart:convert';

/// 分析API服务
/// 负责与后端埋点接口通信
@injectable
class AnalyticsApiService {
  final Dio _dio;
  
  static const String _dauEndpoint = '/api/project/dau/add';
  
  AnalyticsApiService(this._dio);

  /// 记录单个事件
  Future<Map<String, dynamic>> recordEvent(AnalyticsEvent event) async {
    AppLogger.d('[AnalyticsApiService] 开始上报单个事件: ${event.businessType}, 路径: ${event.path}, ID: ${event.businessId}');
    
    try {
      final response = await _dio.post(
        _dauEndpoint,
        data: event.toApiJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          // 设置超时时间
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        AppLogger.d('[AnalyticsApiService] 事件上报成功: ${response.statusCode}, 响应: ${response.data}');
        
        // 处理不同类型的响应
        if (response.data is Map<String, dynamic>) {
          return response.data;
        } else if (response.data is String) {
          // 尝试解析字符串响应为JSON
          try {
            // 如果字符串为空，返回默认成功响应
            if (response.data == null || (response.data as String).isEmpty) {
              return {'msg': '操作成功', 'code': 200};
            }
            
            // 尝试将字符串解析为JSON
            final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
              jsonDecode(response.data as String)
            );
            return jsonData;
          } catch (e) {
            AppLogger.d('[AnalyticsApiService] 无法解析响应字符串为JSON: $e');
            // 返回一个带有原始字符串的成功响应
            return {
              'msg': response.data as String,
              'code': 200,
              'raw_response': response.data
            };
          }
        } else {
          // 对于其他类型的响应，返回一个带有类型信息的成功响应
          return {
            'msg': '操作成功',
            'code': 200,
            'response_type': response.data?.runtimeType.toString() ?? 'null'
          };
        }
      } else {
        AppLogger.d('[AnalyticsApiService] 事件上报失败: ${response.statusCode}, 响应: ${response.data}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '埋点上报失败: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.d('[AnalyticsApiService] 事件上报网络错误: ${e.message}, 状态码: ${e.response?.statusCode}, 响应: ${e.response?.data}');
      // 网络错误，重新抛出以便上层处理
      rethrow;
    } catch (e) {
      AppLogger.d('[AnalyticsApiService] 事件上报未知错误: $e');
      // 其他错误
      throw DioException(
        requestOptions: RequestOptions(path: _dauEndpoint),
        message: '埋点上报异常: $e',
      );
    }
  }

  /// 批量记录事件
  Future<List<Map<String, dynamic>>> batchRecordEvents(
    List<AnalyticsEvent> events,
  ) async {
    AppLogger.d('[AnalyticsApiService] 开始批量上报 ${events.length} 个事件');
    
    final results = <Map<String, dynamic>>[];
    final errors = <String>[];

    // 并发上报，但限制并发数量
    const batchSize = 5;
    for (int i = 0; i < events.length; i += batchSize) {
      final batch = events.skip(i).take(batchSize).toList();
      AppLogger.d('[AnalyticsApiService] 处理批次 ${i ~/ batchSize + 1}/${(events.length / batchSize).ceil()}, 本批次 ${batch.length} 个事件');
      
      final futures = batch.map((event) async {
        try {
          return await recordEvent(event);
        } catch (e) {
          final errorMsg = '事件上报失败: ${event.businessType}, 路径: ${event.path}, 错误: $e';
          errors.add(errorMsg);
          return {'error': e.toString(), 'code': -1};
        }
      });

      final batchResults = await Future.wait(futures);
      results.addAll(batchResults);
    }

    // 如果有错误，记录日志但不抛异常
    if (errors.isNotEmpty) {
      AppLogger.d('[AnalyticsApiService] 批量上报部分失败: ${errors.length}/${events.length} 个事件失败');
      for (int i = 0; i < errors.length; i++) {
        AppLogger.d('[AnalyticsApiService] 失败详情 ${i + 1}/${errors.length}: ${errors[i]}');
      }
    } else {
      AppLogger.d('[AnalyticsApiService] 批量上报全部成功: ${events.length} 个事件');
    }

    return results;
  }

  /// 测试连接
  Future<bool> testConnection() async {
    AppLogger.d('[AnalyticsApiService] 开始测试埋点API连接');
    
    try {
      final testEvent = AnalyticsEvent(
        businessType: 'test',
        path: '/test',
        feature: {'test': true},
      );
      
      await recordEvent(testEvent);
      AppLogger.d('[AnalyticsApiService] 连接测试成功');
      return true;
    } catch (e) {
      AppLogger.d('[AnalyticsApiService] 连接测试失败: $e');
      return false;
    }
  }
} 