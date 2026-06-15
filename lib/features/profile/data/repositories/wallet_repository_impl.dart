import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/repositories/i_wallet_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/transaction_dto.dart';

/// 钱包仓库实现
@Injectable(as: IWalletRepository)
class WalletRepositoryImpl implements IWalletRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  WalletRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, WalletSummary>> getWalletSummary() async {
    if (await networkInfo.isConnected) {
      try {
        final walletSummaryDto = await remoteDataSource.getWalletSummary();
        return Right(walletSummaryDto.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(GeneralFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: '无网络连接'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionDto>>> getWalletTransactions({
    required int page,
    required int pageSize,
    String? startDate,
    String? endDate,
    required String transactionType,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final transactions = await remoteDataSource.getWalletTransactions(
          page: page,
          pageSize: pageSize,
          startDate: startDate,
          endDate: endDate,
          transactionType: transactionType,
        );
        return Right(transactions);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(GeneralFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: '无网络连接'));
    }
  }

  @override
  Future<Either<Failure, void>> submitWithdrawal({
    required double amount,
    required String idempotencyToken,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.submitWithdrawal(
          amount: amount,
          idempotencyToken: idempotencyToken,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(GeneralFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: '无网络连接'));
    }
  }
}
