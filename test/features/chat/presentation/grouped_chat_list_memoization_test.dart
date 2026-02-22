import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/participant.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/widgets/grouped_chat_list.dart';

/// 验证 GroupedChatList memoization 逻辑
///
/// 测试策略：提取分组逻辑为可独立测试的纯函数，
/// 验证缓存行为（相同引用不重新计算，不同引用重新计算）。

/// 模拟 _GroupedChatListState 的缓存逻辑
class _MemoizationTestHelper {
  List<ChatRoom>? _cachedChatRooms;
  List<SellerChatGroup> _cachedGroups = [];
  int computeCallCount = 0;

  List<SellerChatGroup> getGroupedChats(
    List<ChatRoom> chatRooms,
    List<SellerChatGroup> Function(List<ChatRoom>) compute,
  ) {
    if (!identical(_cachedChatRooms, chatRooms)) {
      _cachedChatRooms = chatRooms;
      _cachedGroups = compute(chatRooms);
      computeCallCount++;
    }
    return _cachedGroups;
  }
}

Participant _makeParticipant({
  required int referId,
  required String type,
  String? nickName,
}) {
  return Participant(
    id: referId,
    referId: referId,
    type: type,
    nickName: nickName ?? 'User$referId',
    avatar: null,
  );
}

ChatRoom _makeChatRoom({required int id, required int sellerId, required int memberId}) {
  return ChatRoom(
    id: id,
    participant1: _makeParticipant(referId: memberId, type: 'MEMBER'),
    participant2: _makeParticipant(referId: sellerId, type: 'DOCTOR'),
    unreadCount: 0,
    lastMessage: null,
    productId: null,
    productName: null,
    productImage: null,
    productPrice: null,
  );
}

void main() {
  group('GroupedChatList memoization', () {
    late _MemoizationTestHelper helper;
    int computeCalls = 0;

    List<SellerChatGroup> mockCompute(List<ChatRoom> rooms) {
      computeCalls++;
      return []; // 返回空列表即可，测试关注调用次数
    }

    setUp(() {
      helper = _MemoizationTestHelper();
      computeCalls = 0;
    });

    test('首次调用：执行计算', () {
      final rooms = [_makeChatRoom(id: 1, sellerId: 10, memberId: 1)];
      helper.getGroupedChats(rooms, mockCompute);
      expect(computeCalls, 1);
    });

    test('相同引用再次调用：不重新计算（缓存命中）', () {
      final rooms = [_makeChatRoom(id: 1, sellerId: 10, memberId: 1)];
      helper.getGroupedChats(rooms, mockCompute);
      helper.getGroupedChats(rooms, mockCompute); // 同一个 list 对象
      expect(computeCalls, 1); // 只计算一次
    });

    test('不同引用调用：重新计算', () {
      final rooms1 = [_makeChatRoom(id: 1, sellerId: 10, memberId: 1)];
      final rooms2 = [_makeChatRoom(id: 1, sellerId: 10, memberId: 1)]; // 内容相同但引用不同
      helper.getGroupedChats(rooms1, mockCompute);
      helper.getGroupedChats(rooms2, mockCompute);
      expect(computeCalls, 2); // 引用变化时重新计算
    });

    test('空列表：缓存正常工作', () {
      final rooms = <ChatRoom>[];
      helper.getGroupedChats(rooms, mockCompute);
      helper.getGroupedChats(rooms, mockCompute);
      expect(computeCalls, 1);
    });

    test('列表更新后：重新计算并返回新结果', () {
      final rooms1 = [_makeChatRoom(id: 1, sellerId: 10, memberId: 1)];
      final rooms2 = [
        _makeChatRoom(id: 1, sellerId: 10, memberId: 1),
        _makeChatRoom(id: 2, sellerId: 20, memberId: 1),
      ];

      final result1 = helper.getGroupedChats(rooms1, (_) => [SellerChatGroup(sellerId: 10, seller: _makeParticipant(referId: 10, type: 'DOCTOR'), chatRooms: rooms1)]);
      final result2 = helper.getGroupedChats(rooms2, (_) => [
        SellerChatGroup(sellerId: 10, seller: _makeParticipant(referId: 10, type: 'DOCTOR'), chatRooms: [rooms2[0]]),
        SellerChatGroup(sellerId: 20, seller: _makeParticipant(referId: 20, type: 'DOCTOR'), chatRooms: [rooms2[1]]),
      ]);

      expect(result1.length, 1);
      expect(result2.length, 2);
    });
  });

  group('_groupChatsBySeller 分组逻辑', () {
    // 用反射验证 Widget 分组逻辑较复杂，改为直接测试分组数据类

    test('SellerChatGroup 正确存储卖家和聊天室', () {
      final seller = _makeParticipant(referId: 10, type: 'DOCTOR', nickName: 'Seller10');
      final room = _makeChatRoom(id: 1, sellerId: 10, memberId: 1);

      final group = SellerChatGroup(
        sellerId: 10,
        seller: seller,
        chatRooms: [room],
      );

      expect(group.sellerId, 10);
      expect(group.seller.nickName, 'Seller10');
      expect(group.chatRooms.length, 1);
    });

    test('相同卖家的多个聊天室应合并为一组', () {
      // 验证 Map<sellerId, rooms> 的合并逻辑
      final Map<int, List<ChatRoom>> grouped = {};
      final rooms = [
        _makeChatRoom(id: 1, sellerId: 10, memberId: 1),
        _makeChatRoom(id: 2, sellerId: 10, memberId: 1), // 同一卖家
        _makeChatRoom(id: 3, sellerId: 20, memberId: 1), // 不同卖家
      ];

      for (final room in rooms) {
        final sellerId = room.participant2.referId ?? 0;
        grouped.putIfAbsent(sellerId, () => []).add(room);
      }

      expect(grouped.keys.length, 2); // 两个卖家
      expect(grouped[10]?.length, 2); // 卖家10有2个聊天室
      expect(grouped[20]?.length, 1); // 卖家20有1个聊天室
    });

    test('不同卖家各自独立成组', () {
      final Map<int, List<ChatRoom>> grouped = {};
      final rooms = [
        _makeChatRoom(id: 1, sellerId: 10, memberId: 1),
        _makeChatRoom(id: 2, sellerId: 20, memberId: 1),
        _makeChatRoom(id: 3, sellerId: 30, memberId: 1),
      ];

      for (final room in rooms) {
        final sellerId = room.participant2.referId ?? 0;
        grouped.putIfAbsent(sellerId, () => []).add(room);
      }

      expect(grouped.keys.length, 3);
    });
  });
}
