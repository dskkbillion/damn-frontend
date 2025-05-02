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
        return SellerUpgradeStatisticsDto.fromJson(response.data['data']);
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
        return SellerIndexStatisticsDto.fromJson(response.data['data']);
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
        return SellerPercentStatisticsDto.fromJson(response.data['data']);
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