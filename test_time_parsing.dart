import 'package:dskk_flutter_refactor/features/chat/data/models/chat_message_dto.dart';

void main() {
  print('=== 测试时间解析修复 ===');
  
  // 测试API返回的时间格式
  final testJson = {
    'id': 1,
    'chatId': 89,
    'context': '测试消息',
    'type': 'text',
    'createTime': '2025-05-14 09:49:46', // API返回的格式
    'withdrawFlag': false,
  };
  
  try {
    final dto = ChatMessageDto.fromJson(testJson);
    print('✅ DTO创建成功: $dto');
    
    final entity = dto.toEntity(currentUserId: 1, senderId: 2);
    print('✅ Entity转换成功');
    print('📅 解析的时间: ${entity.createTime}');
    print('🕐 格式化时间: ${entity.createTime?.toString()}');
    
    // 验证时间是否正确解析
    if (entity.createTime != null) {
      final expectedTime = DateTime(2025, 5, 14, 9, 49, 46);
      if (entity.createTime!.isAtSameMomentAs(expectedTime)) {
        print('🎉 时间解析完全正确！');
      } else {
        print('❌ 时间解析不正确');
        print('   期望: $expectedTime');
        print('   实际: ${entity.createTime}');
      }
    } else {
      print('❌ 时间解析失败，createTime为null');
    }
    
  } catch (e) {
    print('❌ 测试失败: $e');
  }
  
  print('\n=== 测试完成 ===');
} 