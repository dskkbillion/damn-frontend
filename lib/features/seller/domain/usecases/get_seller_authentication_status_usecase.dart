import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:injectable/injectable.dart';

/// 获取卖家认证状态列表UseCase
@injectable
class GetSellerAuthenticationStatusUseCase implements UseCase<List<SellerAuthenticationInfo>, NoParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  GetSellerAuthenticationStatusUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, List<SellerAuthenticationInfo>>> call(NoParams params) {
    return _sellerRepository.getAuthenticationStatus();
  }
} 