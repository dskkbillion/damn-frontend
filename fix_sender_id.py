import re

# 读取文件
with open('lib/features/chat/data/repositories/chat_repository_impl.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 定义要替换的模式
old_pattern = r'''            // 根据消息中的memberId和doctorId判断senderId（使用participant的内部ID）
            int senderParticipantId;
            if \(sentMessageDto\.memberId != null && sentMessageDto\.doctorId == null\) \{
              senderParticipantId = room\.participant1\.id; // 买家是participant1
              print\("\[Repository\] 发送的消息: memberId=\$\{sentMessageDto\.memberId\}，买家发送，senderId=\$\{senderParticipantId\}"\);
            \} else if \(sentMessageDto\.doctorId != null && sentMessageDto\.memberId == null\) \{
              senderParticipantId = room\.participant2\.id; // 卖家是participant2
              print\("\[Repository\] 发送的消息: doctorId=\$\{sentMessageDto\.doctorId\}，卖家发送，senderId=\$\{senderParticipantId\}"\);
            \} else if \(sentMessageDto\.memberId != null && sentMessageDto\.doctorId != null\) \{
              // 两者都有值，根据当前用户类型判断
              if \(user\.type == 'MEMBER'\) \{
                senderParticipantId = room\.participant1\.id; // 买家是participant1
                print\("\[Repository\] 发送的消息: 两者都有值，当前用户是买家，使用participant1\.id作为senderId=\$\{senderParticipantId\}"\);
              \} else \{
                senderParticipantId = room\.participant2\.id; // 卖家是participant2
                print\("\[Repository\] 发送的消息: 两者都有值，当前用户是卖家，使用participant2\.id作为senderId=\$\{senderParticipantId\}"\);
              \}
            \} else \{
              // 理论上不应该出现两者都为空的情况，使用当前用户对应的participant ID
              if \(user\.type == 'MEMBER'\) \{
                senderParticipantId = room\.participant1\.id;
              \} else \{
                senderParticipantId = room\.participant2\.id;
              \}
              print\("\[Repository\] 发送的消息: memberId和doctorId都为空，设置senderId为0"\);
            \}'''

new_text = '''            // 重要修正：在ChatRoomDto.toEntity中，participant1总是当前用户，participant2总是对方
            // 所以发送消息时，senderId应该总是使用participant1.id（当前用户）
            int senderParticipantId = room.participant1.id; // participant1总是当前用户

            print("[Repository] 发送的消息: 当前用户发送，senderId=${senderParticipantId}");
            print("[Repository] 调试信息: participant1.id=${room.participant1.id} (当前用户), participant2.id=${room.participant2.id} (对方)");
            print("[Repository] 调试信息: user.id=${user.id}, user.type=${user.type}");
            print("[Repository] 调试信息: memberId=${sentMessageDto.memberId}, doctorId=${sentMessageDto.doctorId}");'''

# 执行替换
modified_content = re.sub(old_pattern, new_text, content, flags=re.MULTILINE)

# 如果没有找到匹配，尝试更简单的方式
if modified_content == content:
    # 查找行号
    lines = content.split('\n')
    start_idx = -1
    for i, line in enumerate(lines):
        if 'int senderParticipantId;' in line:
            start_idx = i - 1  # 包括注释行
            break
    
    if start_idx >= 0:
        # 找到结束位置（打印语句结束）
        end_idx = start_idx + 1
        for i in range(start_idx + 1, len(lines)):
            if 'print("[Repository] 发送的消息: memberId和doctorId都为空' in lines[i]:
                end_idx = i + 1
                break
        
        # 替换这部分
        new_lines = new_text.split('\n')
        lines = lines[:start_idx] + new_lines + lines[end_idx:]
        modified_content = '\n'.join(lines)
        print(f"Replaced lines {start_idx+1} to {end_idx+1}")

# 写回文件
with open('lib/features/chat/data/repositories/chat_repository_impl.dart', 'w', encoding='utf-8') as f:
    f.write(modified_content)

print("File modified successfully!")
