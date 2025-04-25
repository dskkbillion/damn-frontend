import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 标记所有通知为已读参数
class MarkAllNotificationsAsReadParams extends Equatable {
  /// 通知类型（可选）
  final String? messageTypes;

  /// 构造函数
  const MarkAllNotificationsAsReadParams({
    this.messageTypes,
  });

  @override
  List<Object?> get props => [messageTypes];
}

/// 标记所有通知为已读UseCase
@injectable
class MarkAllNotificationsAsReadUseCase implements UseCase<bool, MarkAllNotificationsAsReadParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  MarkAllNotificationsAsReadUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, bool>> call(MarkAllNotificationsAsReadParams params) {
    return _sellerRepository.markAllNotificationsAsRead(
      messageTypes: params.messageTypes,
    );
  }
} 