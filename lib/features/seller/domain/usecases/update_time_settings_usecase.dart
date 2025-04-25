import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/time_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 更新时间设置参数
class UpdateTimeSettingsParams extends Equatable {
  /// 时间设置数据
  final TimeSettingsData settings;

  /// 构造函数
  const UpdateTimeSettingsParams({
    required this.settings,
  });

  @override
  List<Object> get props => [settings];
}

/// 更新时间设置UseCase
@injectable
class UpdateTimeSettingsUseCase implements UseCase<bool, UpdateTimeSettingsParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  UpdateTimeSettingsUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, bool>> call(UpdateTimeSettingsParams params) {
    return _sellerRepository.updateTimeSettings(params.settings);
  }
} 