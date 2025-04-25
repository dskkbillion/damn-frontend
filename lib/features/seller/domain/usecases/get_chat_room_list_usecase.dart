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
@injectable
class GetChatRoomListUseCase implements UseCase<List<ChatSession>, GetChatRoomListParams> {
  final IChatRepository _chatRepository;

  /// 构造函数
  GetChatRoomListUseCase(this._chatRepository);

  @override
  Future<Either<Failure, List<ChatSession>>> call(GetChatRoomListParams params) {
    return _chatRepository.getChatRoomList(params.userId);
  }
} 