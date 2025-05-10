import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_notification.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 获取卖家通知列表参数
class GetSellerNotificationListParams extends Equatable {
  /// 通知类型（可选）
  final String? messageType;
  
  /// 页码
  final int pageNum;
  
  /// 每页数量
  final int pageSize;

  /// 构造函数
  const GetSellerNotificationListParams({
    this.messageType,
    this.pageNum = 1,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [messageType, pageNum, pageSize];
}

/// 获取卖家通知列表UseCase
@injectable
class GetSellerNotificationListUseCase
    implements UseCase<List<SellerNotification>, GetSellerNotificationListParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  GetSellerNotificationListUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, List<SellerNotification>>> call(
      GetSellerNotificationListParams params) {
    return _sellerRepository.getNotificationList(
      messageType: params.messageType,
      pageNum: params.pageNum,
      pageSize: params.pageSize,
    );
  }
} 