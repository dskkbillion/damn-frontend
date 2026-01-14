import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'i_seller_statistics_data_source.dart';
import '../models/seller_statistics_dtos.dart';

/// 卖家统计数据源实现
@Injectable(as: ISellerStatisticsDataSource)
class SellerStatisticsDataSourceImpl implements ISellerStatisticsDataSource {
  final Dio dio;

  /// 构造函数，注入Dio
  SellerStatisticsDataSourceImpl(this.dio);

  @override
  Future<SellerUpgradeStatisticsDto> getUpgradeStatistics() async {
    try {
      final response = await dio.post('/api/project/statistics/upgradeLevel');
      print('[SellerStatistics] upgradeLevel response: ${response.data}');
      if (response.statusCode == 200) {
        // 检查业务逻辑层的 code
        final responseCode = response.data['code'];
        if (responseCode != null && responseCode != 200) {
          final msg = response.data['msg'] ?? '服务器错误';
          print('[SellerStatistics] upgradeLevel business error: $msg');
          throw ServerException(message: msg);
        }
        final data = response.data['data'];
        if (data == null) {
          print('[SellerStatistics] upgradeLevel data is null');
          throw ServerException(message: '升级统计数据为空');
        }
        return SellerUpgradeStatisticsDto.fromJson(data as Map<String, dynamic>);
      } else {
        throw ServerException(message: '服务器响应错误: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[SellerStatistics] upgradeLevel DioException: ${e.message}');
      throw ServerException(message: e.message ?? '网络请求失败');
    } catch (e) {
      print('[SellerStatistics] upgradeLevel error: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SellerIndexStatisticsDto> getIndexStatistics() async {
    try {
      final response = await dio.post('/api/project/statistics/index');
      print('[SellerStatistics] index response: ${response.data}');
      if (response.statusCode == 200) {
        // 检查业务逻辑层的 code
        final responseCode = response.data['code'];
        if (responseCode != null && responseCode != 200) {
          final msg = response.data['msg'] ?? '服务器错误';
          print('[SellerStatistics] index business error: $msg');
          throw ServerException(message: msg);
        }
        final data = response.data['data'];
        if (data == null) {
          print('[SellerStatistics] index data is null');
          throw ServerException(message: '指标统计数据为空');
        }
        return SellerIndexStatisticsDto.fromJson(data as Map<String, dynamic>);
      } else {
        throw ServerException(message: '服务器响应错误: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[SellerStatistics] index DioException: ${e.message}');
      throw ServerException(message: e.message ?? '网络请求失败');
    } catch (e) {
      print('[SellerStatistics] index error: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SellerPercentStatisticsDto> getPercentStatistics() async {
    try {
      final response = await dio.post('/api/project/statistics/percent');
      print('[SellerStatistics] percent response: ${response.data}');
      if (response.statusCode == 200) {
        // 检查业务逻辑层的 code
        final responseCode = response.data['code'];
        if (responseCode != null && responseCode != 200) {
          final msg = response.data['msg'] ?? '服务器错误';
          print('[SellerStatistics] percent business error: $msg');
          throw ServerException(message: msg);
        }
        final data = response.data['data'];
        if (data == null) {
          print('[SellerStatistics] percent data is null');
          throw ServerException(message: '百分比统计数据为空');
        }
        return SellerPercentStatisticsDto.fromJson(data as Map<String, dynamic>);
      } else {
        throw ServerException(message: '服务器响应错误: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[SellerStatistics] percent DioException: ${e.message}');
      throw ServerException(message: e.message ?? '网络请求失败');
    } catch (e) {
      print('[SellerStatistics] percent error: $e');
      throw ServerException(message: e.toString());
    }
  }
}
