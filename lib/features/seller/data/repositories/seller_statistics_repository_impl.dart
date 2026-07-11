import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/i_seller_statistics_data_source.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_statistics.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_dashboard_data.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_statistics_repository.dart';

/// 卖家统计数据仓库实现
@Injectable(as: ISellerStatisticsRepository)
class SellerStatisticsRepositoryImpl implements ISellerStatisticsRepository {
  final ISellerStatisticsDataSource dataSource;
  final NetworkInfo networkInfo;
  
  /// 构造函数，注入依赖
  SellerStatisticsRepositoryImpl(
    this.dataSource,
    this.networkInfo,
  );
  
  @override
  Future<Either<Failure, SellerUpgradeStatistics>> getUpgradeStatistics() async {
    if (await networkInfo.isConnected) {
      try {
        final dto = await dataSource.getUpgradeStatistics();
        final entity = SellerUpgradeStatistics(
          days: dto.days,
          orderNum: dto.orderNum,
          orderPrice: dto.orderPrice,
          totalDays: dto.totalDays,
          totalOrderNum: dto.totalOrderNum,
          totalOrderPrice: dto.totalOrderPrice,
        );
        return Right(entity);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: '无网络连接'));
    }
  }
  
  @override
  Future<Either<Failure, SellerIndexStatistics>> getIndexStatistics() async {
    if (await networkInfo.isConnected) {
      try {
        final response = await dataSource.getIndexStatistics();
        final dto = response.statistics;
        final entity = SellerIndexStatistics(
          totalEarnings: dto.totalEarnings,
          thisMonthTotalEarnings: dto.thisMonthTotalEarnings,
          totalOrderNum: dto.totalOrderNum,
          activeOrderNum: dto.activeOrderNum,
          pendingOrderNum: dto.pendingOrderNum,
          receiptOrderNum: dto.receiptOrderNum,
          earlyTime: dto.earlyTime,
          latenessTime: dto.latenessTime,
          weeklyIncome: response.weeklyIncome
              .map((item) => WeeklyIncomeItem(date: item.date, amount: item.amount))
              .toList(growable: false),
        );
        return Right(entity);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: '无网络连接'));
    }
  }
  
  @override
  Future<Either<Failure, SellerPercentStatistics>> getPercentStatistics() async {
    if (await networkInfo.isConnected) {
      try {
        final dto = await dataSource.getPercentStatistics();
        final entity = SellerPercentStatistics(
          heatPercent: dto.heatPercent,
          recoverPercent: dto.recoverPercent,
          completePercent: dto.completePercent,
          goodPercent: dto.goodPercent,
        );
        return Right(entity);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '服务器异常'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: '无网络连接'));
    }
  }
} 
