import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/user_info.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_info_repository.dart';
import 'package:dskk_flutter_refactor/features/auth/data/datasources/user_info_remote_data_source.dart';

@LazySingleton(as: IUserInfoRepository) // Register implementation for the interface
@injectable
class UserInfoRepositoryImpl implements IUserInfoRepository {
  final UserInfoRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo; // Inject network info for connectivity check

  UserInfoRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserInfo>> fetchUserInfo(String token) async {
    if (await networkInfo.isConnected) {
      try {
        final userInfoModel = await remoteDataSource.fetchUserInfo(token);
        // UserInfoModel now extends UserInfo, so we can return it directly.
        return Right(userInfoModel);
      } on UnauthenticatedException catch (e) {
        print('UnauthenticatedException in UserInfoRepository: ${e.message}');
        return Left(AuthenticationFailure(message: e.message));
      } on ServerException catch (e) {
        print('ServerException in UserInfoRepository: ${e.message}');
        return Left(ServerFailure(message: e.message ?? '获取用户信息时发生服务器错误'));
      } catch (e) {
        print('Unknown exception in UserInfoRepository: ${e.toString()}');
        return Left(UnknownFailure(message: 'Failed to fetch user info'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
