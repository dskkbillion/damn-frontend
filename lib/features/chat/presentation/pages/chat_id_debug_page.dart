import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_chat_room_list.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';

/// 聊天系统ID调试页面
/// 用于诊断和验证聊天室创建和查询中的ID使用问题
class ChatIdDebugPage extends StatefulWidget {
  const ChatIdDebugPage({super.key});

  @override
  State<ChatIdDebugPage> createState() => _ChatIdDebugPageState();
}

class _ChatIdDebugPageState extends State<ChatIdDebugPage> {
  final _targetReferIdController = TextEditingController();
  final _productIdController = TextEditingController();
  String _debugInfo = '';
  String? _currentUserReferId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserInfo();
  }

  Future<void> _loadCurrentUserInfo() async {
    try {
      final secureStorage = GetIt.instance<FlutterSecureStorage>();
      final referIdStr = await secureStorage.read(key: 'refer_id');
      
      setState(() {
        _currentUserReferId = referIdStr;
        _debugInfo = '当前用户 refer_id: $referIdStr\n';
      });
    } catch (e) {
      setState(() {
        _debugInfo = '获取当前用户信息失败: $e\n';
      });
    }
  }

  Future<void> _testCreateChatRoom() async {
    final targetReferId = int.tryParse(_targetReferIdController.text);
    final productId = int.tryParse(_productIdController.text);
    
    if (targetReferId == null) {
      setState(() {
        _debugInfo += '\n错误：目标用户referId无效\n';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _debugInfo += '\n===== 创建聊天室测试 =====\n';
      _debugInfo += '目标用户referId: $targetReferId\n';
      _debugInfo += '商品ID: ${productId ?? "无"}\n';
    });

    try {
      final chatRepository = GetIt.instance<IChatRepository>();
      final result = await chatRepository.createRoom(
        targetReferId,
        productId: productId,
      );

      result.fold(
        (failure) {
          setState(() {
            _debugInfo += '创建失败: ${failure.message}\n';
          });
        },
        (chatId) {
          setState(() {
            _debugInfo += '创建成功！聊天室ID: $chatId\n';
            _debugInfo += '提示：请登录对方账号查看是否能看到此聊天室\n';
          });
        },
      );
    } catch (e) {
      setState(() {
        _debugInfo += '发生异常: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetChatRooms() async {
    setState(() {
      _isLoading = true;
      _debugInfo += '\n===== 获取聊天室列表测试 =====\n';
    });

    try {
      final getChatRoomList = GetIt.instance<GetChatRoomList>();
      final result = await getChatRoomList(NoParams());

      result.fold(
        (failure) {
          setState(() {
            _debugInfo += '获取失败: ${failure.message}\n';
          });
        },
        (chatRooms) {
          setState(() {
            _debugInfo += '获取成功！共 ${chatRooms.length} 个聊天室\n';
            
            for (final room in chatRooms) {
              _debugInfo += '\n聊天室 ${room.id}:\n';
              _debugInfo += '  - 参与者1: type=${room.participant1.type}, referId=${room.participant1.referId}, id=${room.participant1.id}\n';
              _debugInfo += '  - 参与者2: type=${room.participant2.type}, referId=${room.participant2.referId}, id=${room.participant2.id}\n';
              
              // 判断当前用户在聊天室中的角色
              final currentReferId = int.tryParse(_currentUserReferId ?? '');
              if (currentReferId != null) {
                if (room.participant1.referId == currentReferId) {
                  _debugInfo += '  - 当前用户是participant1 (${room.participant1.type})\n';
                  _debugInfo += '  - 对方是participant2: ${room.participant2.nickName}\n';
                } else if (room.participant2.referId == currentReferId) {
                  _debugInfo += '  - 当前用户是participant2 (${room.participant2.type})\n';
                  _debugInfo += '  - 对方是participant1: ${room.participant1.nickName}\n';
                } else {
                  _debugInfo += '  - ⚠️ 警告：当前用户不在此聊天室中！\n';
                }
              }
            }
          });
        },
      );
    } catch (e) {
      setState(() {
        _debugInfo += '发生异常: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天系统ID调试'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '当前用户信息',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Refer ID: ${_currentUserReferId ?? "未获取"}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '创建聊天室测试',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _targetReferIdController,
                      decoration: const InputDecoration(
                        labelText: '目标用户 Refer ID',
                        hintText: '输入对方的refer_id',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _productIdController,
                      decoration: const InputDecoration(
                        labelText: '商品ID（可选）',
                        hintText: '输入商品ID，留空则不关联商品',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testCreateChatRoom,
                          child: const Text('创建聊天室'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testGetChatRooms,
                          child: const Text('获取聊天室列表'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '调试信息',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            ),
                            child: SelectableText(
                              _debugInfo,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _targetReferIdController.dispose();
    _productIdController.dispose();
    super.dispose();
  }
}