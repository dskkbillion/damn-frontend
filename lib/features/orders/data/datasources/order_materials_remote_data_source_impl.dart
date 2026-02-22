import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/order_materials_model.dart';
import '../models/order_delivery_model.dart';
import 'i_order_materials_remote_data_source.dart';

@LazySingleton(as: IOrderMaterialsRemoteDataSource)
class OrderMaterialsRemoteDataSourceImpl implements IOrderMaterialsRemoteDataSource {
  final Dio _dio;

  OrderMaterialsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<OrderMaterialsModel>> getOrderMaterials(int orderId) async {
    try {
      final response = await _dio.post(
        '/api/project/orderMaterials/list',
        data: {
          'orderId': orderId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['code'] == 200) {
          final rows = data['rows'] as List<dynamic>? ?? [];
          return rows
              .map((item) => OrderMaterialsModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(message: data['msg'] ?? '获取订单材料失败');
        }
      } else {
        throw ServerException(message: '获取订单材料失败');
      }
    } on DioException catch (e) {
      AppLogger.d('获取订单材料失败: ${e.message}');
      throw ServerException(message: e.message ?? '网络错误');
    } catch (e) {
      AppLogger.d('获取订单材料出错: $e');
      throw ServerException(message: '获取订单材料出错: $e');
    }
  }

  @override
  Future<List<OrderDeliveryModel>> getOrderDeliveries(int orderId) async {
    try {
      final response = await _dio.post(
        '/api/project/orderDelivery/list',
        data: {
          'orderId': orderId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['code'] == 200) {
          final rows = data['rows'] as List<dynamic>? ?? [];
          return rows
              .map((item) => OrderDeliveryModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(message: data['msg'] ?? '获取订单交付失败');
        }
      } else {
        throw ServerException(message: '获取订单交付失败');
      }
    } on DioException catch (e) {
      AppLogger.d('获取订单交付失败: ${e.message}');
      throw ServerException(message: e.message ?? '网络错误');
    } catch (e) {
      AppLogger.d('获取订单交付出错: $e');
      throw ServerException(message: '获取订单交付出错: $e');
    }
  }

  @override
  Future<OrderMaterialsModel> getOrderMaterialById(int materialId) async {
    try {
      final response = await _dio.get('/api/project/orderMaterials/get?id=$materialId');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['code'] == 200 && data['data'] != null) {
          return OrderMaterialsModel.fromJson(data['data'] as Map<String, dynamic>);
        } else {
          throw ServerException(message: data['msg'] ?? '获取材料详情失败');
        }
      } else {
        throw ServerException(message: '获取材料详情失败');
      }
    } on DioException catch (e) {
      AppLogger.d('获取材料详情失败: ${e.message}');
      throw ServerException(message: e.message ?? '网络错误');
    } catch (e) {
      AppLogger.d('获取材料详情出错: $e');
      throw ServerException(message: '获取材料详情出错: $e');
    }
  }

  @override
  Future<OrderDeliveryModel> getOrderDeliveryById(int deliveryId) async {
    try {
      final response = await _dio.get('/api/project/orderDelivery/get?id=$deliveryId');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['code'] == 200 && data['data'] != null) {
          return OrderDeliveryModel.fromJson(data['data'] as Map<String, dynamic>);
        } else {
          throw ServerException(message: data['msg'] ?? '获取交付详情失败');
        }
      } else {
        throw ServerException(message: '获取交付详情失败');
      }
    } on DioException catch (e) {
      AppLogger.d('获取交付详情失败: ${e.message}');
      throw ServerException(message: e.message ?? '网络错误');
    } catch (e) {
      AppLogger.d('获取交付详情出错: $e');
      throw ServerException(message: '获取交付详情出错: $e');
    }
  }
}