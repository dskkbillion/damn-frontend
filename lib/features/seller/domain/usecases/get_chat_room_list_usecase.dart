import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_chat_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 获取聊天室列表参数
class GetChatRoomListParams extends Equatable {
  /// 用户ID
  final int userId;

  /// 构造函数
  const GetChatRoomListParams({
    required this.userId,
  });

  @override
  List<Object> get props => [userId];
}

/// 获取聊天室列表UseCase
/// 
/// 注意：此实现已废弃，seller模块不应使用它。
/// 应该使用chat模块中的统一实现。
@deprecated // 使用Dart标准的废弃注解
@injectable
class LegacyGetChatRoomListUseCase implements UseCase<List<ChatSession>, GetChatRoomListParams> {
  final IChatRepository _chatRepository;

  /// 构造函数
  LegacyGetChatRoomListUseCase(this._chatRepository);

  @override
  Future<Either<Failure, List<ChatSession>>> call(GetChatRoomListParams params) {
    return _chatRepository.getChatRoomList(params.userId);
  }
} 