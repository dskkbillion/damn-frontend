import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_statistics.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_statistics_repository.dart';

/// 获取卖家百分比统计数据用例
@injectable
class GetSellerPercentStatisticsUseCase implements UseCase<SellerPercentStatistics, NoParams> {
  final ISellerStatisticsRepository repository;
  
  /// 构造函数，注入仓库
  GetSellerPercentStatisticsUseCase(this.repository);
  
  @override
  Future<Either<Failure, SellerPercentStatistics>> call(NoParams params) {
    return repository.getPercentStatistics();
  }
} 