import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_allocation_result_entity.dart';
import '../repositories/i_ai_chat_repository.dart';
import '../../../chat/domain/usecases/create_chat_room.dart';
import '../../../chat/domain/repositories/i_chat_repository.dart';

/// {@template optimized_allocation_usecase}
/// 优化的分发用例：先创建聊天室，再进行AI分发，最后发送消息
/// 这样可以确保用户能立即进入聊天室，即使AI分发失败也不影响聊天功能
/// {@endtemplate}
@lazySingleton
class OptimizedAllocationUseCase 
    implements UseCase<OptimizedAllocationResult, OptimizedAllocationParams> {
      
  final IAiChatRepository _aiRepository;
  final IChatRepository _chatRepository;
  final CreateChatRoom _createChatRoom;

  /// {@macro optimized_allocation_usecase}
  OptimizedAllocationUseCase(
    this._aiRepository,
    this._chatRepository,
    this._createChatRoom,
  );

  @override
  Future<Either<Failure, OptimizedAllocationResult>> call(
      OptimizedAllocationParams params) async {

    print('[OptimizedAllocation] 开始执行 - conversationId: ${params.conversationId}, userId: ${params.userId}, merchantId: ${params.merchantId}');
    print('[OptimizedAllocation] 商品数据: ${params.item}');

    try {
      // 第一步：创建聊天室（如果已存在会返回现有聊天室ID）
      print('[OptimizedAllocation] 第1步: 准备创建聊天室...');
      final productId = int.tryParse(params.item['id']?.toString() ?? '');
      print('[OptimizedAllocation] productId解析结果: $productId (原始值: ${params.item['id']})');

      final createRoomResult = await _createChatRoom(CreateChatRoomParams(
        participantId: params.merchantId,
        productId: productId,
      ));

      print('[OptimizedAllocation] 创建聊天室结果: ${createRoomResult.isRight() ? "成功" : "失败"}');

      if (createRoomResult.isLeft()) {
        final failure = createRoomResult.fold((l) => l, (r) => throw Exception());
        print('[OptimizedAllocation] ❌ 创建聊天室失败: $failure');
        return Left(failure);
      }

      final chatRoomId = createRoomResult.fold((l) => throw Exception(), (r) => r);
      print('[OptimizedAllocation] ✅ 聊天室已创建/获取，chatRoomId: $chatRoomId');

      // 第二步：进行AI分发
      print('[OptimizedAllocation] 第2步: 准备调用AI分发API...');
      final allocationResult = await _aiRepository.allocateChatResource(
        conversationId: params.conversationId,
        userId: params.userId,
        item: params.item,
        merchantId: params.merchantId,
      );

      print('[OptimizedAllocation] AI分发结果: ${allocationResult.isRight() ? "成功" : "失败"}');
      
      // 第三步：无论AI分发是否成功，都返回聊天室ID
      // 这样用户可以立即进入聊天室
      return allocationResult.fold(
        (failure) {
          // AI分发失败，但聊天室已创建成功
          return Right(OptimizedAllocationResult(
            chatRoomId: chatRoomId,
            allocationSuccess: false,
            summary: '聊天室已创建，但AI分发失败：${failure.toString()}',
            errorMessage: failure.toString(),
          ));
        },
        (allocation) {
          // AI分发成功
          return Right(OptimizedAllocationResult(
            chatRoomId: chatRoomId,
            allocationSuccess: true,
            summary: allocation.summary,
            errorMessage: null,
          ));
        },
      );
      
    } catch (e) {
      return Left(ServerFailure(message: '优化分发过程中发生错误: $e'));
    }
  }
}

/// {@template optimized_allocation_params}
/// 优化分发用例的参数
/// {@endtemplate}
class OptimizedAllocationParams extends Equatable {
  final int conversationId;
  final int userId;
  final Map<String, dynamic> item;
  final int merchantId;

  /// {@macro optimized_allocation_params}
  const OptimizedAllocationParams({
    required this.conversationId,
    required this.userId,
    required this.item,
    required this.merchantId,
  });

  @override
  List<Object?> get props => [
        conversationId,
        userId,
        item,
        merchantId,
      ];
}

/// {@template optimized_allocation_result}
/// 优化分发的结果
/// {@endtemplate}
class OptimizedAllocationResult extends Equatable {
  final int chatRoomId;
  final bool allocationSuccess;
  final String summary;
  final String? errorMessage;

  /// {@macro optimized_allocation_result}
  const OptimizedAllocationResult({
    required this.chatRoomId,
    required this.allocationSuccess,
    required this.summary,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        chatRoomId,
        allocationSuccess,
        summary,
        errorMessage,
      ];
} 