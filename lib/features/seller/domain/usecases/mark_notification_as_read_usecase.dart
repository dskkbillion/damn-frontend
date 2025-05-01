import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 标记通知为已读参数
class MarkNotificationAsReadParams extends Equatable {
  /// 通知ID
  final String notificationId;

  /// 构造函数
  const MarkNotificationAsReadParams({
    required this.notificationId,
  });

  @override
  List<Object> get props => [notificationId];
}

/// 标记通知为已读UseCase
@injectable
class MarkNotificationAsReadUseCase implements UseCase<bool, MarkNotificationAsReadParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  MarkNotificationAsReadUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, bool>> call(MarkNotificationAsReadParams params) {
    return _sellerRepository.markNotificationAsRead(params.notificationId);
  }
} 