import 'package:equatable/equatable.dart';

/// 通用错误/失败类型
/// 可以根据项目实际情况扩展为更具体的错误类型
/// (例如 NetworkFailure, CacheFailure, ServerFailure)
class Failure extends Equatable {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  const Failure(this.message, {this.error, this.stackTrace});

  @override
  List<Object?> get props => [message, error, stackTrace];

  @override
  String toString() {
    return 'Failure{message: $message, error: $error}';
  }
}

// 可以定义一些常用的 Failure 子类
class ServerFailure extends Failure {
  const ServerFailure(String message, {dynamic error, StackTrace? stackTrace})
      : super(message, error: error, stackTrace: stackTrace);
}

class CacheFailure extends Failure {
  const CacheFailure(String message, {dynamic error, StackTrace? stackTrace})
      : super(message, error: error, stackTrace: stackTrace);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, {dynamic error, StackTrace? stackTrace})
      : super(message, error: error, stackTrace: stackTrace);
} 