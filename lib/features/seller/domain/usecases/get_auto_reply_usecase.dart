import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/auto_reply_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:injectable/injectable.dart';

/// 获取自动回复设置UseCase
@injectable
class GetAutoReplyUseCase implements UseCase<AutoReplySettings, NoParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  GetAutoReplyUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, AutoReplySettings>> call(NoParams params) {
    return _sellerRepository.getAutoReplySettings();
  }
} 