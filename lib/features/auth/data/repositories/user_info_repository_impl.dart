import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/user_info.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_info_repository.dart';
import 'package:dskk_flutter_refactor/features/auth/data/datasources/user_info_remote_data_source.dart';

@LazySingleton(
    as: IUserInfoRepository) // Register implementation for the interface
@injectable
class UserInfoRepositoryImpl implements IUserInfoRepository {
  static const Duration _defaultNetworkProbeTimeout = Duration(seconds: 3);

  final UserInfoRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo; // Inject network info for connectivity check
  final Duration networkProbeTimeout;

  UserInfoRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    this.networkProbeTimeout = _defaultNetworkProbeTimeout,
  });

  @override
  Future<Either<Failure, UserInfo>> fetchUserInfo(String token) async {
    try {
      final isConnected = await networkInfo.isConnected.timeout(
        networkProbeTimeout,
        onTimeout: () {
          // Let Dio's request timeout decide reachability when the simulator's
          // connectivity probe does not answer.
          AppLogger.d(
              'Network connectivity probe timed out; proceeding with request.');
          return true;
        },
      );
      if (!isConnected) {
        return const Left(NetworkFailure(message: '网络连接不可用'));
      }

      try {
        final userInfoModel = await remoteDataSource.fetchUserInfo(token);
        // UserInfoModel now extends UserInfo, so we can return it directly.
        return Right(userInfoModel);
      } on UnauthenticatedException catch (e) {
        AppLogger.d(
            'UnauthenticatedException in UserInfoRepository: ${e.message}');
        return Left(AuthenticationFailure(message: e.message));
      } on ServerException catch (e) {
        AppLogger.d('ServerException in UserInfoRepository: ${e.message}');
        return Left(ServerFailure(message: e.message ?? '获取用户信息时发生服务器错误'));
      } catch (e) {
        AppLogger.d('Unknown exception in UserInfoRepository: ${e.toString()}');
        return const Left(UnknownFailure(message: 'Failed to fetch user info'));
      }
    } catch (e) {
      AppLogger.d('Network preflight failed: ${e.runtimeType}');
      return const Left(UnknownFailure(message: 'Failed to fetch user info'));
    }
  }
}
