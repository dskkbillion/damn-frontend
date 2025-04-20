import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/saved_item.dart';
import '../../domain/repositories/i_saved_item_repository.dart';
import '../datasources/profile_remote_data_source.dart';

/// 收藏项目仓库实现
class SavedItemRepositoryImpl implements ISavedItemRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SavedItemRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<SavedItem>>> getSavedItems({
    int page = 1,
    int pageSize = 10,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final savedItems = await remoteDataSource.getSavedItems(
          page: page,
          pageSize: pageSize,
        );
        return Right(savedItems.map((item) => item.toEntity()).toList());
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
