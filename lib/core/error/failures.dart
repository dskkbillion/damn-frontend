import 'package:equatable/equatable.dart';

/// 失败基类
abstract class Failure extends Equatable {
  @override
  List<Object?> get props => [];
}

/// 服务器失败
class ServerFailure extends Failure {
  final String? message;

  ServerFailure({this.message});

  @override
  List<Object?> get props => [message];
}

/// 缓存失败
class CacheFailure extends Failure {}