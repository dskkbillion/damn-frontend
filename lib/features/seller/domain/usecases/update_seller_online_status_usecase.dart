import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 更新卖家在线状态参数
class UpdateSellerOnlineStatusParams extends Equatable {
  /// 是否在线
  final bool isOnline;

  /// 构造函数
  const UpdateSellerOnlineStatusParams({
    required this.isOnline,
  });

  @override
  List<Object> get props => [isOnline];
}

/// 更新卖家在线状态UseCase
@injectable
class UpdateSellerOnlineStatusUseCase implements UseCase<bool, UpdateSellerOnlineStatusParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  UpdateSellerOnlineStatusUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, bool>> call(UpdateSellerOnlineStatusParams params) {
    return _sellerRepository.updateOnlineStatus(params.isOnline);
  }
} 