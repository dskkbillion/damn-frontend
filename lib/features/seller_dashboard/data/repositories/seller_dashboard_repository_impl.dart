import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart'; // Corrected import
// import '../../../../core/network/network_info.dart'; // Optional: if you check network status
import '../../domain/entities/seller_dashboard_data.dart';
import '../../domain/repositories/seller_dashboard_repository.dart';
// Import the DataSource interface (to be created next)
import '../datasources/seller_dashboard_remote_data_source.dart';
// Import DTOs/Models if needed for mapping (to be created later)
import '../models/percent_data_dto.dart';
import '../models/upgrade_level_data_dto.dart';
import '../models/index_data_dto.dart';
// Import Auth Repository interface to get token
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart'; // Corrected import & Example path

// TODO: Define AuthenticationFailure if it doesn't exist in core/error/failures.dart
// Example:
// class AuthenticationFailure extends Failure {
//   AuthenticationFailure({String message = "Authentication Failed"}) : super(message: message);
// }

class SellerDashboardRepositoryImpl implements ISellerDashboardRepository {
  final SellerDashboardRemoteDataSource remoteDataSource;
  final IAuthRepository authRepository; // Inject auth repository
  // final NetworkInfo networkInfo; // Optional

  SellerDashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository, // Require auth repository
    // required this.networkInfo,
  });

  @override
  Future<Either<Failure, SellerDashboardData>> getDashboardData() async {
    // TODO: Network check if needed

    try {
      // 1. Get the token first
      final tokenEither = await authRepository.getToken();

      // Handle potential failure during token retrieval
      final String token = tokenEither.fold(
        (failure) => throw AuthenticationException(), // Throw specific exception if token fails
        (token) => token ?? '', // Use the token if successful, handle potential null
      );

      // If token is empty or invalid, you might want to throw here too
      if (token.isEmpty) {
         throw AuthenticationException(message: "Auth token is empty");
      }

      // 2. Proceed with data fetching using the obtained token
      final results = await Future.wait([
        remoteDataSource.getPercentData(token: token),
        remoteDataSource.getUpgradeLevelData(token: token),
        remoteDataSource.getIndexData(token: token),
      ]);

      // 3. Extract DTOs
      final percentData = results[0] as PercentDataDto;
      final upgradeData = results[1] as UpgradeLevelDataDto;
      final indexData = results[2] as IndexDataDto;

      // 4. Map DTOs to Entity
      final dashboardData = SellerDashboardData(
        heatPercent: percentData.heatPercent,
        recoverPercent: percentData.recoverPercent,
        completePercent: percentData.completePercent,
        goodPercent: percentData.goodPercent,
        days: upgradeData.days,
        orderNum: upgradeData.orderNum,
        orderPrice: upgradeData.orderPrice,
        totalDays: upgradeData.totalDays,
        upgradeProgressOrderCount: upgradeData.totalOrderNum,
        totalOrderPrice: upgradeData.totalOrderPrice,
        totalEarnings: indexData.totalEarnings,
        thisMonthTotalEarnings: indexData.thisMonthTotalEarnings,
        overallTotalOrderCount: indexData.totalOrderNum,
        activeOrderNum: indexData.activeOrderNum,
        pendingOrderNum: indexData.pendingOrderNum,
        receiptOrderNum: indexData.receiptOrderNum,
        earlyTime: indexData.earlyTime,
        latenessTime: indexData.latenessTime,
      );

      return Right(dashboardData);

    // 5. Error Handling & Mapping
    } on AuthenticationException catch(e) {
       print("Authentication Error in Repository: ${e.message}");
       // Now uses the message from the exception, providing a default
       return Left(AuthenticationFailure(message: e.message ?? "Authentication Failed"));
    } on ServerException catch (e) {
      // Provide default message if e.message is null
      return Left(ServerFailure(message: e.message ?? 'Unknown Server Error', statusCode: e.statusCode));
    } on ParsingException catch (e) {
      // Provide default message if e.message is null
      return Left(ParsingFailure(message: e.message ?? 'Data Parsing Error'));
    } on NetworkException catch (e) {
       // Provide default message if e.message is null
       return Left(NetworkFailure(message: e.message ?? 'Network Connection Error'));
    } catch (e, s) {
      print("Unexpected error in Repository: $e\n$s");
      // Use e.toString() which is guaranteed non-null
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

// // Define AuthenticationException if needed (can be in core/error/exceptions.dart)
// class AuthenticationException extends AppException {
//   const AuthenticationException({String? message, StackTrace? stackTrace})
//       : super(message ?? 'Authentication Error', stackTrace);
// } 