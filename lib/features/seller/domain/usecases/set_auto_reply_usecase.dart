import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/auto_reply_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 设置自动回复参数
class SetAutoReplyParams extends Equatable {
  /// 自动回复设置
  final AutoReplySettings settings;

  /// 构造函数
  const SetAutoReplyParams({
    required this.settings,
  });

  @override
  List<Object> get props => [settings];
}

/// 设置自动回复UseCase
@injectable
class SetAutoReplyUseCase implements UseCase<bool, SetAutoReplyParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  SetAutoReplyUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, bool>> call(SetAutoReplyParams params) {
    return _sellerRepository.setAutoReplySettings(params.settings);
  }
} 