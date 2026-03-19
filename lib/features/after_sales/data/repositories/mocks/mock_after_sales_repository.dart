import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/after_sales_application.dart';
import '../../../domain/repositories/i_after_sales_repository.dart';

// Helper function to create mock data easily
AfterSalesApplication _createMockApplication({
  required int id,
  required int orderId,
  required int orderItemId,
  required String refundType, // "ONLY_MONEY", "MONEY_AND_PRODUCT"
  required String refundState, // "WAIT_AUDIT", "AUDIT_PASS", "AUDIT_REFUSED", etc.
  String? refundReason = '商品与描述不符',
  String? refundExplain = '收到的商品颜色和图片差异太大，希望退款。',
  List<String>? refundImage = const [
    'https://via.placeholder.com/150/FF0000/FFFFFF?text=Proof1',
    'https://via.placeholder.com/150/00FF00/FFFFFF?text=Proof2',
  ],
  double refundPrice = 99.9,
  String? refundAddress,
  String? auditRemark,
  DateTime? createTime,
}) {
  return AfterSalesApplication(
    id: id,
    orderId: orderId,
    orderItemId: orderItemId,
    productId: 101 + id,
    variantId: 202 + id,
    productName: '模拟服务商品 $id',
    variantName: '标准规格',
    productImage: 'https://via.placeholder.com/150',
    refundSn: 'REFUNDSN$id',
    refundType: refundType,
    refundReason: refundReason,
    refundExplain: refundExplain,
    refundImage: refundState == 'WAIT_AUDIT' ? refundImage : [], // Only show images in initial state?
    refundNumber: refundType == 'MONEY_AND_PRODUCT' ? 1 : null,
    refundPrice: refundPrice,
    refundState: refundState,
    finalState: refundState == 'AUDIT_PASS' || refundState == 'CONFIRM_RECEIPT' ? 'PASS'
               : refundState == 'AUDIT_REFUSED' ? 'REFUSED'
               : refundState == 'CANCEL' ? 'CANCEL'
               : 'IN_PROGRESS',
    refundAddress: refundState == 'AUDIT_PASS' && refundType == 'MONEY_AND_PRODUCT' ? '模拟退货地址：XX省XX市XX区XX街道XX号' : refundAddress,
    auditRemark: refundState == 'AUDIT_REFUSED' ? '拒绝理由：图片证据不足以支持退款申请。' : auditRemark,
    auditTime: refundState != 'WAIT_AUDIT' ? DateTime.now().subtract(const Duration(days: 1)) : null,
    shipTime: refundState == 'BUYER_SHIP' || refundState == 'CONFIRM_RECEIPT' ? DateTime.now().subtract(const Duration(hours: 12)) : null,
    confirmTime: refundState == 'CONFIRM_RECEIPT' ? DateTime.now().subtract(const Duration(hours: 2)) : null,
    cancelTime: refundState == 'CANCEL' ? DateTime.now().subtract(const Duration(hours: 5)) : null,
    memberType: 'buyer',
    auditType: 'seller',
    refundStateText: _mapStateToText(refundState),
    refundTypeText: refundType == 'ONLY_MONEY' ? '仅退款' : '退货退款',
    createTime: createTime ?? DateTime.now().subtract(const Duration(days: 2)),
    updateTime: DateTime.now().subtract(const Duration(minutes: 30)),
  );
}

String _mapStateToText(String state) {
  switch (state) {
    case 'WAIT_AUDIT': return '待审核';
    case 'AUDIT_PASS': return '审核通过';
    case 'AUDIT_REFUSED': return '审核拒绝';
    case 'BUYER_SHIP': return '待卖家收货';
    case 'CONFIRM_RECEIPT': return '退款成功'; // Assuming confirm receipt means success
    case 'CANCEL': return '已取消';
    default: return '处理中';
  }
}

// Predefined mock list
final List<AfterSalesApplication> _mockApplications = [
  _createMockApplication(id: 1, orderId: 1001, orderItemId: 2001, refundType: 'ONLY_MONEY', refundState: 'WAIT_AUDIT', refundPrice: 50.0),
  _createMockApplication(id: 2, orderId: 1002, orderItemId: 2002, refundType: 'MONEY_AND_PRODUCT', refundState: 'AUDIT_PASS', refundPrice: 150.0),
  _createMockApplication(id: 3, orderId: 1003, orderItemId: 2003, refundType: 'ONLY_MONEY', refundState: 'AUDIT_REFUSED', refundReason: '其他原因', refundExplain: '就是不想要了。'),
  _createMockApplication(id: 4, orderId: 1004, orderItemId: 2004, refundType: 'MONEY_AND_PRODUCT', refundState: 'BUYER_SHIP', refundPrice: 88.0),
  _createMockApplication(id: 5, orderId: 1005, orderItemId: 2005, refundType: 'ONLY_MONEY', refundState: 'CONFIRM_RECEIPT', refundPrice: 25.5), // Example successful refund
  _createMockApplication(id: 6, orderId: 1006, orderItemId: 2006, refundType: 'MONEY_AND_PRODUCT', refundState: 'CANCEL', refundReason: '买家取消'),
];


// Using String environments for now, ensure these match your injectable setup
// const String envDev = 'dev'; // Keep commented out or remove if not used elsewhere
// const String envTest = 'test';

// @Injectable(as: IAfterSalesRepository, env: [envDev, envTest]) // Remove env property
// @Injectable(as: IAfterSalesRepository) // Keep it simple for now
class MockAfterSalesRepository implements IAfterSalesRepository {

  @override
  Future<Either<Failure, int>> applyForAfterSales(ApplyAfterSalesParams params) async {
    AppLogger.d('[MockAfterSalesRepository] applyForAfterSales called with params: $params');
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

    // Simulate successful application, return a new mock ID
    final newId = (_mockApplications.isNotEmpty ? _mockApplications.map((a) => a.id).reduce((a, b) => a > b ? a : b) : 0) + 1;
    final newApp = _createMockApplication(
      id: newId,
      orderId: 0, // We don't have orderId in params, maybe fetch from orderItemId later?
      orderItemId: params.orderItemId,
      refundType: params.refundType,
      refundState: 'WAIT_AUDIT', // Application starts in 'WAIT_AUDIT'
      refundReason: params.refundReason,
      refundExplain: params.refundExplain,
      refundImage: params.refundImage,
      // refundPrice needs to be determined or mocked, using default for now
    );
    _mockApplications.add(newApp); // Add to our mock list
    AppLogger.d('[MockAfterSalesRepository] New application created with ID: $newId');
    return Right(newId);

    // Simulate failure example:
    // return Left(ServerFailure(message: 'Mock Server Error: Failed to apply for refund.'));
  }

  @override
  Future<Either<Failure, List<AfterSalesApplication>>> getAfterSalesList(GetAfterSalesListParams params) async {
     AppLogger.d('[MockAfterSalesRepository] getAfterSalesList called with params: $params');
     await Future.delayed(const Duration(milliseconds: 500));

     // Simple filtering mock
     List<AfterSalesApplication> results = _mockApplications;
     if (params.stateFilter != null && params.stateFilter!.isNotEmpty) {
       results = results.where((app) => app.refundState == params.stateFilter).toList();
     }

     // Simple pagination mock
     final startIndex = (params.page - 1) * params.pageSize;
     final endIndex = startIndex + params.pageSize;
     final paginatedResults = results.sublist(
       startIndex.clamp(0, results.length),
       endIndex.clamp(0, results.length),
     );

     AppLogger.d('[MockAfterSalesRepository] Returning ${paginatedResults.length} applications for page ${params.page}');
     return Right(paginatedResults);

     // Simulate failure example:
     // return Left(NetworkFailure());
  }

  @override
  Future<Either<Failure, AfterSalesApplication>> getAfterSalesDetail(int refundId) async {
    AppLogger.d('[MockAfterSalesRepository] getAfterSalesDetail called for refundId: $refundId');
    await Future.delayed(const Duration(milliseconds: 200));

    try {
       final application = _mockApplications.firstWhere((app) => app.id == refundId);
       AppLogger.d('[MockAfterSalesRepository] Found application detail for ID: $refundId');
       return Right(application);
    } catch (e) {
       AppLogger.d('[MockAfterSalesRepository] Application not found for ID: $refundId');
       return Left(ServerFailure(message: 'Mock Error: Refund application not found.'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAfterSales(int refundId) async {
     AppLogger.d('[MockAfterSalesRepository] cancelAfterSales called for refundId: $refundId');
     await Future.delayed(const Duration(milliseconds: 150));

     final index = _mockApplications.indexWhere((app) => app.id == refundId);
     if (index != -1 && (_mockApplications[index].refundState == 'WAIT_AUDIT' || _mockApplications[index].refundState == 'AUDIT_PASS')) { // Only cancel specific states
        // Simulate cancellation by changing state (in a real mock, might need immutable updates)
        // For simplicity, we just print here. Ideally, update the mock list state.
        AppLogger.d('[MockAfterSalesRepository] Successfully cancelled refund ID: $refundId');
        return const Right(null);
     } else if (index != -1) {
        AppLogger.d('[MockAfterSalesRepository] Cannot cancel refund ID: $refundId in state ${_mockApplications[index].refundState}');
        return Left(ServerFailure(message: 'Mock Error: Cannot cancel refund in the current state.'));
     } else {
        AppLogger.d('[MockAfterSalesRepository] Refund ID: $refundId not found for cancellation.');
        return Left(ServerFailure(message: 'Mock Error: Refund application not found.'));
     }
  }

  @override
  Future<Either<Failure, void>> applyMediation(int refundId) async {
    AppLogger.d('[MockAfterSalesRepository] applyMediation called for refundId: $refundId');
    await Future.delayed(const Duration(milliseconds: 150));

    final index = _mockApplications.indexWhere((app) => app.id == refundId);
    if (index == -1) {
      return Left(ServerFailure(message: 'Mock Error: Refund application not found.'));
    }

    final current = _mockApplications[index];
    if (current.refundState != 'AUDIT_REFUSED') {
      return Left(ServerFailure(message: 'Mock Error: Current refund state does not allow mediation.'));
    }

    _mockApplications[index] = _createMockApplication(
      id: current.id,
      orderId: current.orderId,
      orderItemId: current.orderItemId,
      refundType: current.refundType,
      refundState: current.refundState,
      refundReason: current.refundReason,
      refundExplain: current.refundExplain,
      refundImage: current.refundImage,
      refundPrice: current.refundPrice ?? 0,
      refundAddress: current.refundAddress,
      auditRemark: '已申请平台介入',
    );

    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAfterSales(List<int> refundIds) async {
     AppLogger.d('[MockAfterSalesRepository] deleteAfterSales called for refundIds: $refundIds');
     await Future.delayed(const Duration(milliseconds: 100));

     // Simulate deletion (just print for now)
     // In a real mock, remove items from _mockApplications list
     AppLogger.d('[MockAfterSalesRepository] Successfully deleted refund records for IDs: $refundIds');
     return const Right(null);

     // Simulate failure example:
     // return Left(ServerFailure(message: 'Mock Error: Failed to delete records.'));
  }

  @override
  Future<Either<Failure, int?>> getRefundIdByOrderId(int orderId) async {
    AppLogger.d('[MockAfterSalesRepository] getRefundIdByOrderId called for orderId: $orderId');
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final application = _mockApplications.firstWhere((app) => app.orderId == orderId);
      return Right(application.id);
    } catch (e) {
      return const Right(null);
    }
  }
} 
