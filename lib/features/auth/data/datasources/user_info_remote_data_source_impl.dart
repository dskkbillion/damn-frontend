import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/features/auth/data/datasources/user_info_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/auth/data/models/user_info_model.dart';

@LazySingleton(as: UserInfoRemoteDataSource) // Register implementation for the interface
@injectable
class UserInfoRemoteDataSourceImpl implements UserInfoRemoteDataSource {
  final Dio dio;

  UserInfoRemoteDataSourceImpl(this.dio);

  @override
  Future<UserInfoModel> fetchUserInfo(String token) async {
    const String endpoint = '/api/member/info'; // Endpoint from API spec

    try {
      final response = await dio.get(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Include token in header
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        try {
          // Assuming UserInfoModel has a fromJson factory
          return UserInfoModel.fromJson(response.data);
        } catch (e) {
          print('Error parsing user info response: $e');
          throw ServerException(message: 'Failed to parse user info response.');
        }
      } else {
        print('Fetch user info API returned status ${response.statusCode} or null data.');
        throw ServerException(
            message: 'Failed to fetch user info. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException during fetch user info: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw UnauthenticatedException(message: 'Invalid token');
      }
      throw ServerException(message: 'Fetch user info failed due to network or server error.');
    } catch (e) {
      print('Unknown error during fetch user info: ${e.toString()}');
      throw ServerException(message: 'An unknown error occurred while fetching user info.');
    }
  }
}
