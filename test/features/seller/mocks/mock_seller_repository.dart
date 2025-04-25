import 'package:mockito/mockito.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dartz/dartz.dart';

// Seller模块仓库接口
abstract class ISellerRepository {
  // 仪表盘/统计数据
  Future<Either<Failure, Map<String, dynamic>>> getDashboardData();
  
  // 商品管理
  Future<Either<Failure, Map<String, dynamic>>> getSellerProductList({
    required int pageNum,
    required int pageSize,
    String? state,
  });
  
  Future<Either<Failure, Map<String, dynamic>>> getSellerDraftList({
    required int pageNum,
    required int pageSize,
  });
  
  Future<Either<Failure, Map<String, dynamic>>> getProductDetail(int productId);
  
  Future<Either<Failure, bool>> updateProductStatus(int productId, String state);
  
  Future<Either<Failure, bool>> createProduct(Map<String, dynamic> productData);
  
  Future<Either<Failure, bool>> updateProduct(Map<String, dynamic> productData);
  
  Future<Either<Failure, bool>> deleteProduct(List<int> productIds);
  
  // 通知管理
  Future<Either<Failure, List<dynamic>>> getNotificationList({String? messageType});
  
  Future<Either<Failure, bool>> markNotificationAsRead(String notificationId);
  
  Future<Either<Failure, bool>> markAllNotificationsAsRead({String? messageTypes});
  
  Future<Either<Failure, int>> getUnreadNotificationCount();
  
  // 售后管理
  Future<Either<Failure, Map<String, dynamic>>> getTenantAuditList({
    required int pageNum,
    required int pageSize,
  });
  
  Future<Either<Failure, bool>> auditRefund({
    required int id,
    required String refundState,
    String? auditRemark,
  });
  
  Future<Either<Failure, Map<String, dynamic>>> getRefundDetail(int refundId);
  
  // 认证管理
  Future<Either<Failure, List<dynamic>>> getAuthenticationStatusList();
  
  Future<Either<Failure, bool>> submitAuthenticationApplication(Map<String, dynamic> applicationData);
  
  // 订单交付
  Future<Either<Failure, bool>> addOrderDelivery({
    required int orderId,
    required String content,
    required List<String> files,
  });
}

class MockSellerRepository extends Mock implements ISellerRepository {
  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboardData() async {
    // 模拟仪表盘数据
    return Right({
      'income': {
        'total': 10000.0,
        'today': 1200.0,
        'pending': 3000.0,
      },
      'orders': {
        'total': 50,
        'pending': 10,
        'completed': 35,
        'canceled': 5,
      },
      'rating': 4.8,
      'notifications': {
        'unread': 5,
      },
      'statistics': {
        'weeklyIncome': [
          {'date': '2023-11-01', 'amount': 800.0},
          {'date': '2023-11-02', 'amount': 1200.0},
          {'date': '2023-11-03', 'amount': 600.0},
          {'date': '2023-11-04', 'amount': 1500.0},
          {'date': '2023-11-05', 'amount': 900.0},
          {'date': '2023-11-06', 'amount': 1100.0},
          {'date': '2023-11-07', 'amount': 1300.0},
        ],
      }
    });
  }
  
  @override
  Future<Either<Failure, Map<String, dynamic>>> getSellerProductList({
    required int pageNum,
    required int pageSize,
    String? state,
  }) async {
    // 模拟商品列表
    return Right({
      'code': 200,
      'msg': 'success',
      'total': 10,
      'rows': List.generate(3, (index) => {
        'id': 2000 + index,
        'name': '测试商品${index + 1}',
        'price': 100.0 + (index * 50),
        'images': 'https://example.com/product${index}.jpg',
        'description': '这是测试商品${index + 1}的详细描述',
        'state': state ?? 'NORMAL',
        'createTime': '2023-11-0${index + 1} 10:00:00',
        'updateTime': '2023-11-0${index + 1} 15:00:00',
        'sales': 10 + index,
        'category': {'id': 10, 'name': '测试分类'},
      }).toList(),
    });
  }
  
  @override
  Future<Either<Failure, Map<String, dynamic>>> getSellerDraftList({
    required int pageNum,
    required int pageSize,
  }) async {
    // 模拟草稿列表
    return Right({
      'code': 200,
      'msg': 'success',
      'total': 2,
      'rows': List.generate(2, (index) => {
        'id': 3000 + index,
        'name': '草稿商品${index + 1}',
        'price': 100.0 + (index * 50),
        'images': 'https://example.com/draft${index}.jpg',
        'description': '这是草稿商品${index + 1}的详细描述',
        'state': 'DRAFT',
        'createTime': '2023-11-0${index + 1} 10:00:00',
        'updateTime': '2023-11-0${index + 1} 15:00:00',
        'category': {'id': 10, 'name': '测试分类'},
      }).toList(),
    });
  }
  
  @override
  Future<Either<Failure, Map<String, dynamic>>> getProductDetail(int productId) async {
    // 模拟商品详情
    return Right({
      'code': 200,
      'msg': 'success',
      'data': {
        'id': productId,
        'name': '测试商品详情',
        'price': 150.0,
        'images': 'https://example.com/product_detail.jpg',
        'description': '这是测试商品的详细描述，包含产品特点和使用方法',
        'state': 'NORMAL',
        'createTime': '2023-11-01 10:00:00',
        'updateTime': '2023-11-02 15:00:00',
        'sales': 15,
        'category': {'id': 10, 'name': '测试分类'},
        'variants': [
          {
            'id': 1,
            'optionName': '规格',
            'optionValue': '标准版',
            'price': 150.0,
            'stock': 100,
          },
          {
            'id': 2,
            'optionName': '规格',
            'optionValue': '豪华版',
            'price': 250.0,
            'stock': 50,
          }
        ],
        'productMaterials': [
          {
            'id': 1,
            'question': '您的需求是什么?',
            'type': 'TEXT',
          },
          {
            'id': 2,
            'question': '请上传参考资料',
            'type': 'FILE',
          }
        ]
      }
    });
  }
  
  @override
  Future<Either<Failure, bool>> updateProductStatus(int productId, String state) async {
    return Right(true); // 操作成功
  }
  
  @override
  Future<Either<Failure, bool>> createProduct(Map<String, dynamic> productData) async {
    return Right(true); // 操作成功
  }
  
  @override
  Future<Either<Failure, bool>> updateProduct(Map<String, dynamic> productData) async {
    return Right(true); // 操作成功
  }
  
  @override
  Future<Either<Failure, bool>> deleteProduct(List<int> productIds) async {
    return Right(true); // 操作成功
  }
  
  @override
  Future<Either<Failure, List<dynamic>>> getNotificationList({String? messageType}) async {
    // 模拟通知列表
    final now = DateTime.now();
    return Right([
      {
        'id': '1001',
        'type': 'ORDER',
        'title': '新订单通知',
        'content': '您有一个新的订单，请及时处理',
        'isRead': false,
        'createdAt': now.subtract(Duration(hours: 2)).toIso8601String(),
        'relatedEntityId': '1001',
      },
      {
        'id': '1002',
        'type': 'SYSTEM',
        'title': '系统通知',
        'content': '您的账户已通过认证',
        'isRead': true,
        'createdAt': now.subtract(Duration(days: 1)).toIso8601String(),
        'relatedEntityId': null,
      },
      {
        'id': '1003',
        'type': 'MESSAGE',
        'title': '新消息提醒',
        'content': '买家向您发送了一条新消息',
        'isRead': false,
        'createdAt': now.subtract(Duration(hours: 5)).toIso8601String(),
        'relatedEntityId': '2001',
      }
    ]);
  }
  
  @override
  Future<Either<Failure, bool>> markNotificationAsRead(String notificationId) async {
    return Right(true); // 操作成功
  }
  
  @override
  Future<Either<Failure, bool>> markAllNotificationsAsRead({String? messageTypes}) async {
    return Right(true); // 操作成功
  }
  
  @override
  Future<Either<Failure, int>> getUnreadNotificationCount() async {
    return Right(5); // 未读通知数量
  }
  
  @override
  Future<Either<Failure, Map<String, dynamic>>> getTenantAuditList({
    required int pageNum,
    required int pageSize,
  }) async {
    // 模拟售后审核列表
    return Right({
      'code': 200,
      'msg': 'success',
      'total': 3,
      'rows': List.generate(3, (index) => {
        'id': 4000 + index,
        'refundState': 'WAIT_AUDIT',
        'refundType': index % 2 == 0 ? 'ONLY_MONEY' : 'MONEY_AND_PRODUCT',
        'refundReason': '商品不符合描述',
        'refundRemarks': '希望能够退款',
        'refundAmount': 100.0 + (index * 50),
        'createTime': '2023-11-0${index + 1} 10:00:00',
        'order': {
          'id': 1000 + index,
          'orderSn': 'ORD2023110${1000 + index}',
        },
        'orderProductItem': {
          'id': 10000 + index,
          'productName': '测试商品${index + 1}',
          'image': 'https://example.com/product${index}.jpg',
        },
      }).toList(),
    });
  }
  
  @override
  Future<Either<Failure, bool>> auditRefund({
    required int id,
    required String refundState,
    String? auditRemark,
  }) async {
    return Right(true); // 操作成功
  }
  
  @override
  Future<Either<Failure, Map<String, dynamic>>> getRefundDetail(int refundId) async {
    // 模拟售后详情
    return Right({
      'code': 200,
      'msg': 'success',
      'data': {
        'id': refundId,
        'creatorId': 5001,
        'refundState': 'WAIT_AUDIT',
        'refundType': 'ONLY_MONEY',
        'refundReason': '商品不符合描述，颜色与网站展示不一致',
        'refundRemarks': '希望能够全额退款',
        'refundAmount': 150.0,
        'createTime': '2023-11-01 10:00:00',
        'images': 'https://example.com/refund_image1.jpg,https://example.com/refund_image2.jpg',
        'order': {
          'id': 1001,
          'orderSn': 'ORD20231101001',
          'payPrice': 150.0,
        },
        'orderProductItem': {
          'id': 10001,
          'productName': '测试商品1',
          'image': 'https://example.com/product1.jpg',
        },
      }
    });
  }
  
  @override
  Future<Either<Failure, List<dynamic>>> getAuthenticationStatusList() async {
    // 模拟认证状态列表
    return Right([
      {
        'id': 1,
        'name': '身份认证',
        'icon': 'https://example.com/id_icon.png',
        'remarks': '上传身份证正反面进行认证',
        'status': 'OPEN',
        'type': 'ID_CARD',
        'authStatus': 'APPROVED', // 用户认证状态
      },
      {
        'id': 2,
        'name': '学历认证',
        'icon': 'https://example.com/edu_icon.png',
        'remarks': '上传学历证明进行认证',
        'status': 'OPEN',
        'type': 'EDUCATION',
        'authStatus': 'PENDING', // 用户认证状态
      },
      {
        'id': 3,
        'name': '职业认证',
        'icon': 'https://example.com/prof_icon.png',
        'remarks': '上传职业资格证书进行认证',
        'status': 'OPEN',
        'type': 'PROFESSION',
        'authStatus': null, // 未提交认证
      }
    ]);
  }
  
  @override
  Future<Either<Failure, bool>> submitAuthenticationApplication(Map<String, dynamic> applicationData) async {
    return Right(true); // 操作成功
  }
  
  @override
  Future<Either<Failure, bool>> addOrderDelivery({
    required int orderId,
    required String content,
    required List<String> files,
  }) async {
    return Right(true); // 操作成功
  }
} 