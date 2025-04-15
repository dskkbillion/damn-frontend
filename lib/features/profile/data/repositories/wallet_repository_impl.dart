import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/repositories/i_wallet_repository.dart';
import '../datasources/profile_remote_data_source.dart';

/// 钱包仓库实现
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
      return Left(NetworkFailure(message: '无网络连接'));
    }
  }
}
