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

    print('===== 获取用户信息 =====');
    print('请求接口: $endpoint');
    print('请求头: Authorization: Bearer ${token.substring(0, 15)}...(省略)');

    try {
      print('开始发送请求...');
      final response = await dio.get(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Include token in header
          },
        ),
      );

      print('收到服务器响应: 状态码 ${response.statusCode}');
      print('响应数据: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        try {
          // 处理可能的数据结构差异：有些API返回嵌套的data字段
          final userData = response.data is Map && response.data['data'] != null
              ? response.data['data']
              : response.data;

          print('解析用户数据: $userData');

          // 创建默认的UserInfoModel以防返回为空
          if (userData == null) {
            print('警告: 用户数据为空，使用默认值');
            return const UserInfoModel(id: 0);
          }

          // 确保userData是Map类型
          if (userData is! Map<String, dynamic>) {
            print('警告: 用户数据不是预期的Map格式: ${userData.runtimeType}');
            return const UserInfoModel(id: 0);
          }

          return UserInfoModel.fromJson(userData);
        } catch (e) {
          print('错误: 解析用户信息响应失败: $e');
          throw ServerException(message: 'Failed to parse user info response: $e');
        }
      } else {
        print('错误: 获取用户信息API返回状态 ${response.statusCode} 或空数据');
        throw ServerException(
            message: 'Failed to fetch user info. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DIO错误: ${e.message}');
      print('请求信息: ${e.requestOptions.uri}');
      if (e.response != null) {
        print('错误响应状态码: ${e.response?.statusCode}');
        print('错误响应数据: ${e.response?.data}');
      }

      if (e.response?.statusCode == 401) {
        throw UnauthenticatedException(message: 'Invalid token');
      }
      throw ServerException(message: 'Fetch user info failed due to network or server error: ${e.message}');
    } catch (e) {
      print('未知错误: ${e.toString()}');
      throw ServerException(message: 'An unknown error occurred while fetching user info: ${e.toString()}');
    }
  }
}
