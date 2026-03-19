import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/after_sales_application.dart';
import '../../domain/repositories/i_after_sales_repository.dart';
import '../datasources/i_after_sales_remote_data_source.dart';
// Import the model if needed for list conversion, though ideally handled by DataSource
import '../models/after_sales_application_model.dart';


@LazySingleton(as: IAfterSalesRepository)
class AfterSalesRepositoryImpl implements IAfterSalesRepository {
  final IAfterSalesRemoteDataSource remoteDataSource;
  // Add local data source if caching is implemented later
  // final IAfterSalesLocalDataSource localDataSource;

  AfterSalesRepositoryImpl({
    required this.remoteDataSource,
    // required this.localDataSource,
  });

  @override
  Future<Either<Failure, int>> applyForAfterSales(ApplyAfterSalesParams params) async {
    try {
      final resultId = await remoteDataSource.applyForAfterSales(params);
      return Right(resultId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? '申请售后时发生服务器错误'));
    } catch (e) {
      // Catch any other unexpected exceptions during the process
      AppLogger.d('[AfterSalesRepositoryImpl] Unexpected error applying for after sales: ${e.toString()}');
      return Left(ServerFailure(message: '申请售后时发生未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AfterSalesApplication>>> getAfterSalesList(GetAfterSalesListParams params) async {
    try {
      // remoteDataSource returns List<AfterSalesApplicationModel>, which is a List<AfterSalesApplication>
      final List<AfterSalesApplicationModel> models = await remoteDataSource.getAfterSalesList(params);
      // No need to call toEntity() because Model extends Entity
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? '获取售后列表时发生服务器错误'));
    } catch (e) {
       AppLogger.d('[AfterSalesRepositoryImpl] Unexpected error getting after sales list: ${e.toString()}');
      return Left(ServerFailure(message: '获取售后列表时发生未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AfterSalesApplication>> getAfterSalesDetail(int refundId) async {
     try {
      // remoteDataSource returns AfterSalesApplicationModel, which is an AfterSalesApplication
      final model = await remoteDataSource.getAfterSalesDetail(refundId);
      // No need to call toEntity() because Model extends Entity
      return Right(model);
    } on ServerException catch (e) {
      // Handle specific "not found" cases if API provides distinct codes/messages
      // For now, treat all server exceptions similarly
      return Left(ServerFailure(message: e.message ?? '获取售后详情时发生服务器错误'));
    } catch (e) {
       AppLogger.d('[AfterSalesRepositoryImpl] Unexpected error getting after sales detail: ${e.toString()}');
      return Left(ServerFailure(message: '获取售后详情时发生未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAfterSales(int refundId) async {
    try {
      await remoteDataSource.cancelAfterSales(refundId);
      return const Right(null); // Indicate success with void
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? '取消售后申请时发生服务器错误'));
    } catch (e) {
       AppLogger.d('[AfterSalesRepositoryImpl] Unexpected error canceling after sales: ${e.toString()}');
      return Left(ServerFailure(message: '取消售后申请时发生未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> applyMediation(int refundId) async {
    try {
      await remoteDataSource.applyMediation(refundId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? '申请平台介入时发生服务器错误'));
    } catch (e) {
      AppLogger.d('[AfterSalesRepositoryImpl] Unexpected error applying mediation: ${e.toString()}');
      return Left(ServerFailure(message: '申请平台介入时发生未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAfterSales(List<int> refundIds) async {
     try {
      await remoteDataSource.deleteAfterSales(refundIds);
      return const Right(null); // Indicate success with void
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? '删除售后记录时发生服务器错误'));
    } catch (e) {
       AppLogger.d('[AfterSalesRepositoryImpl] Unexpected error deleting after sales: ${e.toString()}');
      return Left(ServerFailure(message: '删除售后记录时发生未知错误: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int?>> getRefundIdByOrderId(int orderId) async {
    try {
      final refundId = await remoteDataSource.getRefundIdByOrderId(orderId);
      return Right(refundId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? '查询售后记录时发生服务器错误'));
    } catch (e) {
      AppLogger.d('[AfterSalesRepositoryImpl] Unexpected error getting refund ID by order ID: ${e.toString()}');
      return Left(ServerFailure(message: '查询售后记录时发生未知错误: ${e.toString()}'));
    }
  }
} 
