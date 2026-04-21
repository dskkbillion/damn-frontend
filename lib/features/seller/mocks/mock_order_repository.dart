import 'package:mockito/mockito.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dartz/dartz.dart';

// 订单仓库接口
abstract class IOrderRepository {
  Future<Either<Failure, Map<String, dynamic>>> getSellerOrderList({
    required int pageNum,
    required int pageSize,
    String? keyword,
    List<String>? states,
  });
  
  Future<Either<Failure, Map<String, dynamic>>> getOrderDetails(int orderId);
  
  Future<Either<Failure, bool>> verifyOrder(int orderId);
  
  Future<Either<Failure, bool>> completeOrder(int orderId);
  
  Future<Either<Failure, bool>> cancelOrder(int orderId);
  
  Future<Either<Failure, bool>> deleteSellerOrder(int orderId);
}

class MockOrderRepository extends Mock implements IOrderRepository {
  @override
  Future<Either<Failure, Map<String, dynamic>>> getSellerOrderList({
    required int pageNum,
    required int pageSize,
    String? keyword,
    List<String>? states,
  }) async {
    // 模拟订单列表响应
    return Right({
      'code': 200,
      'msg': 'success',
      'total': 10,
      'rows': List.generate(3, (index) => {
        'id': 1000 + index,
        'orderSn': 'ORD2023110${1000 + index}',
        'state': states?.isNotEmpty == true ? states!.first : 'awaitingVerification',
        'payPrice': 100.0 + (index * 50),
        'buyer': {
          'id': 5000 + index,
          'nickName': '买家${index + 1}',
          'avatar': 'https://example.com/avatar$index.jpg',
        },
        'tenant': {
          'id': 12345,
          'nickName': '测试卖家',
        },
        'items': [
          {
            'id': 10000 + index,
            'productName': '测试商品${index + 1}',
            'price': 100.0 + (index * 50),
            'number': 1,
            'image': 'https://example.com/product$index.jpg',
          }
        ],
        'createTime': '2023-11-0${index + 1} 10:00:00',
      }).toList(),
    });
  }
  
  @override
  Future<Either<Failure, Map<String, dynamic>>> getOrderDetails(int orderId) async {
    // 模拟订单详情响应
    return Right({
      'code': 200,
      'msg': 'success',
      'data': {
        'id': orderId,
        'orderSn': 'ORD2023110$orderId',
        'state': 'awaitingVerification',
        'payPrice': 150.0,
        'buyer': {
          'id': 5001,
          'nickName': '买家1',
          'avatar': 'https://example.com/avatar1.jpg',
          'mobile': '13800138001',
        },
        'tenant': {
          'id': 12345,
          'nickName': '测试卖家',
        },
        'items': [
          {
            'id': 10001,
            'productName': '测试商品1',
            'price': 150.0,
            'number': 1,
            'image': 'https://example.com/product1.jpg',
          }
        ],
        'createTime': '2023-11-01 10:00:00',
        'payTime': '2023-11-01 10:10:00',
        'remark': '买家备注信息',
      }
    });
  }
  
  @override
  Future<Either<Failure, bool>> verifyOrder(int orderId) async {
    return const Right(true); // 操作成功
  }
  
  @override
  Future<Either<Failure, bool>> completeOrder(int orderId) async {
    return const Right(true); // 操作成功
  }
  
  @override
  Future<Either<Failure, bool>> cancelOrder(int orderId) async {
    return const Right(true); // 操作成功
  }
  
  @override
  Future<Either<Failure, bool>> deleteSellerOrder(int orderId) async {
    return const Right(true); // 操作成功
  }
} 