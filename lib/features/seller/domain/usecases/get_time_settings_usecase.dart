import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/time_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:injectable/injectable.dart';

/// 获取时间设置UseCase
@injectable
class GetTimeSettingsUseCase implements UseCase<TimeSettings, NoParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  GetTimeSettingsUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, TimeSettings>> call(NoParams params) {
    return _sellerRepository.getTimeSettings();
  }
} 