import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_dashboard_data.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:injectable/injectable.dart';

/// 获取卖家仪表盘数据UseCase
@injectable
class GetSellerDashboardDataUseCase implements UseCase<SellerDashboardData, NoParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  GetSellerDashboardDataUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, SellerDashboardData>> call(NoParams params) {
    return _sellerRepository.getDashboardData();
  }
} 