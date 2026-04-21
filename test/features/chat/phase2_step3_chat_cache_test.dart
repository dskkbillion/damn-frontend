import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_local_data_source.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/participant.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/create_chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/delete_chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_chat_room_list.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/bloc/chat_list/chat_list_bloc.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeGetChatRoomList implements GetChatRoomList {
  Either<Failure, List<ChatRoom>>? response;

  @override
  Future<Either<Failure, List<ChatRoom>>> call(NoParams params) async {
    return response!;
  }
}

class _FakeCreateChatRoom implements CreateChatRoom {
  @override
  Future<Either<Failure, int>> call(CreateChatRoomParams params) async {
    return const Right(1);
  }
}

class _FakeDeleteChatRoom implements DeleteChatRoom {
  @override
  Future<Either<Failure, void>> call(DeleteChatRoomParams params) async {
    return const Right(null);
  }
}

class _FakeLocalDataSource implements IChatLocalDataSource {
  List<ChatRoom>? _cachedList;
  List<ChatRoom>? lastCached;

  void seedCache(List<ChatRoom> rooms) {
    _cachedList = rooms;
  }

  @override
  Future<List<ChatRoom>?> getCachedChatRoomList() async => _cachedList;

  @override
  Future<void> cacheChatRoomList(List<ChatRoom> rooms) async {
    lastCached = rooms;
    _cachedList = rooms;
  }

  // --- Unused interface methods (stubs) ---

  @override
  Future<void> cacheMessages(int chatId, List<ChatMessage> messages) async {}

  @override
  Future<List<ChatMessage>?> getCachedMessages(int chatId) async => null;

  @override
  Future<void> clearCachedMessages(int chatId) async {}

  @override
  Future<void> cacheChatRoom(ChatRoom chatRoom) async {}

  @override
  Future<ChatRoom?> getCachedChatRoom(int chatId) async => null;

  @override
  Future<void> clearAllCache() async {}

  @override
  Future<int?> getLastMessageId(int chatId) async => null;

  @override
  Future<void> updateMessageStatus(int messageId, MessageStatus status) async {}

  @override
  Future<void> markMessagesAsRead(int chatId, List<int> messageIds) async {}

  @override
  Future<void> savePaymentPromptStatus(int chatId, bool sent) async {}

  @override
  Future<bool> getPaymentPromptStatus(int chatId) async => false;

  @override
  Future<int> getPaymentPromptCount(int chatId) async => 0;

  @override
  Future<void> savePaymentPromptCount(int chatId, int count) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Participant _makeParticipant(int id) => Participant(
      id: id,
      referId: id,
      type: 'MEMBER',
      nickName: 'User$id',
      avatar: null,
    );

ChatRoom _makeChatRoom(int id) => ChatRoom(
      id: id,
      participant1: _makeParticipant(1),
      participant2: _makeParticipant(2),
      unreadCount: 0,
      lastMessage: null,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  final cachedRooms = [_makeChatRoom(1), _makeChatRoom(2)];
  final freshRooms = [_makeChatRoom(1), _makeChatRoom(2), _makeChatRoom(3)];

  ChatListBloc buildBloc({
    required _FakeGetChatRoomList getChatRoomList,
    required _FakeLocalDataSource localDataSource,
  }) =>
      ChatListBloc(
        getChatRoomList: getChatRoomList,
        createChatRoom: _FakeCreateChatRoom(),
        deleteChatRoom: _FakeDeleteChatRoom(),
        localDataSource: localDataSource,
      );

  group('ChatListBloc — stale-while-revalidate', () {
    test('有缓存时先 emit loaded(isRefreshing: true)，远程成功后 emit loaded(isRefreshing: false)',
        () async {
      final local = _FakeLocalDataSource()..seedCache(cachedRooms);
      final remote = _FakeGetChatRoomList()..response = Right(freshRooms);

      final bloc = buildBloc(getChatRoomList: remote, localDataSource: local);
      final states = <ChatListState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadChatRoomList());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states.length, 2);

      // First: cached data, background refresh in progress
      expect(states[0].status, ChatListStatus.success);
      expect(states[0].chatRooms, cachedRooms);
      expect(states[0].isRefreshing, true);

      // Second: fresh data, refresh complete
      expect(states[1].status, ChatListStatus.success);
      expect(states[1].chatRooms, freshRooms);
      expect(states[1].isRefreshing, false);

      // Cache was updated
      expect(local.lastCached, freshRooms);

      await bloc.close();
    });

    test('有缓存时远程失败 → 保持缓存数据，isRefreshing 变为 false', () async {
      final local = _FakeLocalDataSource()..seedCache(cachedRooms);
      final remote = _FakeGetChatRoomList()
        ..response = const Left(NetworkFailure(message: 'no connection'));

      final bloc = buildBloc(getChatRoomList: remote, localDataSource: local);
      final states = <ChatListState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadChatRoomList());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states.length, 2);

      // First: cached data shown
      expect(states[0].status, ChatListStatus.success);
      expect(states[0].chatRooms, cachedRooms);
      expect(states[0].isRefreshing, true);

      // Second: still success with cached data, refreshing stopped
      expect(states[1].status, ChatListStatus.success);
      expect(states[1].chatRooms, cachedRooms);
      expect(states[1].isRefreshing, false);

      // Cache was NOT overwritten
      expect(local.lastCached, isNull);

      await bloc.close();
    });

    test('无缓存时直接 emit loading，远程成功后 emit success(isRefreshing: false)',
        () async {
      final local = _FakeLocalDataSource(); // no cache
      final remote = _FakeGetChatRoomList()..response = Right(freshRooms);

      final bloc = buildBloc(getChatRoomList: remote, localDataSource: local);
      final states = <ChatListState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadChatRoomList());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states.length, 2);
      expect(states[0].status, ChatListStatus.loading);
      expect(states[1].status, ChatListStatus.success);
      expect(states[1].chatRooms, freshRooms);
      expect(states[1].isRefreshing, false);

      await bloc.close();
    });

    test('无缓存时远程失败 → emit failure state', () async {
      final local = _FakeLocalDataSource(); // no cache
      final remote = _FakeGetChatRoomList()
        ..response = const Left(NetworkFailure(message: 'no connection'));

      final bloc = buildBloc(getChatRoomList: remote, localDataSource: local);
      final states = <ChatListState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadChatRoomList());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states.length, 2);
      expect(states[0].status, ChatListStatus.loading);
      expect(states[1].status, ChatListStatus.failure);
      expect(states[1].isRefreshing, false);

      await bloc.close();
    });
  });
}
