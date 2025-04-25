import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:injectable/injectable.dart';

/// 获取未读通知数量UseCase
@injectable
class GetUnreadNotificationCountUseCase implements UseCase<int, NoParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  GetUnreadNotificationCountUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return _sellerRepository.getUnreadNotificationCount();
  }
} 