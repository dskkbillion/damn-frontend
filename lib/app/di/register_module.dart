import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

@module
abstract class RegisterModule {
  // 注册第三方库 InternetConnectionChecker
  @lazySingleton
  InternetConnectionChecker get internetConnectionChecker =>
      InternetConnectionChecker();

  // 注册第三方库 SharedPreferences (异步注册)
  @preResolve // 告诉 injectable 等待 Future 完成
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  // 注册第三方库 http.Client
  @lazySingleton
  http.Client get httpClient => http.Client();

  // 注意：你可能还需要在这里注册其他在 main_cart.dart 或其他地方手动注册的依赖，
  // 例如 baseUrl, getToken, getUserId 的提供方式，以便 injectable 能够解析。
  // 例如，如果 baseUrl 来自 dotenv，你可能需要：
  // @lazySingleton
  // @Named('baseUrl')
  // String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'default_url';
  //
  // 对于 getToken 和 getUserId，如果它们依赖于 ISecureStorageRepository，
  // 并且 ISecureStorageRepository 及其实现也被 @injectable 注解了，
  // injectable 或许能自动处理。但如果不行，可能需要更复杂的 Module 设置
  // 或者直接在 DataSource 实现中注入 ISecureStorageRepository。
}
