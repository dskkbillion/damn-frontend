import 'package:equatable/equatable.dart';

/// 代表应用中可能发生的通用失败情况的基类。
/// 使用 Equatable 以方便比较。
abstract class Failure extends Equatable {
  // 如果所有子类都传递属性给 super，可以简化 props 的实现
  final List<dynamic> properties;
  const Failure([this.properties = const <dynamic>[]]);

  @override
  List<Object?> get props => properties;
}

/// 表示服务器相关的错误 (例如, API 调用失败, 5xx 错误)
class ServerFailure extends Failure {
  final String? message; // 可选的错误信息
  ServerFailure({this.message}) : super([message]);
}

/// 表示本地缓存相关的错误 (例如, 读取/写入 SharedPreferences 失败)
class CacheFailure extends Failure {
  const CacheFailure() : super();
}

/// 表示认证相关的错误
class AuthFailure extends Failure {
   final String message;
   AuthFailure(this.message) : super([message]);
}

/// 表示网络连接错误
class NetworkFailure extends Failure {
  const NetworkFailure() : super();
}

/// 表示一个简单的、通用的失败情况，通常只包含一个错误消息。
class SimpleFailure extends Failure {
  final String message;
  /*const*/ SimpleFailure(this.message) : super([message]); // Removed const
}

// 未来可以根据需要添加其他特定的 Failure 类型，例如：
// class NetworkFailure extends Failure {}
// class AuthenticationFailure extends Failure {} 