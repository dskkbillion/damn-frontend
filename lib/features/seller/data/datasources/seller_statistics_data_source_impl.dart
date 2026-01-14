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
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          throw ServerException(message: '升级统计数据为空');
        }
        return SellerUpgradeStatisticsDto.fromJson(data as Map<String, dynamic>);
      } else {
        throw ServerException(message: '服务器响应错误: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? '网络请求失败');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
  
  @override
  Future<SellerIndexStatisticsDto> getIndexStatistics() async {
    try {
      final response = await dio.post('/api/project/statistics/index');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          throw ServerException(message: '指标统计数据为空');
        }
        return SellerIndexStatisticsDto.fromJson(data as Map<String, dynamic>);
      } else {
        throw ServerException(message: '服务器响应错误: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? '网络请求失败');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
  
  @override
  Future<SellerPercentStatisticsDto> getPercentStatistics() async {
    try {
      final response = await dio.post('/api/project/statistics/percent');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          throw ServerException(message: '百分比统计数据为空');
        }
        return SellerPercentStatisticsDto.fromJson(data as Map<String, dynamic>);
      } else {
        throw ServerException(message: '服务器响应错误: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? '网络请求失败');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
} 