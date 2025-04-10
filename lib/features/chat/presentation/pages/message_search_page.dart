import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../bloc/message_search/message_search_bloc.dart';
import '../widgets/chat_message_item.dart';
import '../widgets/loading_indicator.dart';
import 'chat_detail_page.dart';

/// 消息搜索页面
class MessageSearchPage extends StatefulWidget {
  /// 页面路由名称
  static const String routeName = '/chat/search';

  /// 会话ID (可选，如果提供则只在该会话内搜索)
  final String? sessionId;

  const MessageSearchPage({
    Key? key,
    this.sessionId,
  }) : super(key: key);

  @override
  State<MessageSearchPage> createState() => _MessageSearchPageState();
}

class _MessageSearchPageState extends State<MessageSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.length >= 2) {
      // 至少2个字符才开始搜索
      _startSearch(query);
    } else if (query.isEmpty) {
      // 清空搜索结果
      context.read<MessageSearchBloc>().add(ClearSearchResultEvent());
    }
  }

  void _startSearch(String query) {
    setState(() {
      _isSearching = true;
    });
    
    context.read<MessageSearchBloc>().add(
      SearchMessagesEvent(
        query: query,
        sessionId: widget.sessionId,
      ),
    );
    
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '搜索消息...',
            border: InputBorder.none,
          ),
          autofocus: true,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: BlocBuilder<MessageSearchBloc, MessageSearchState>(
        builder: (context, state) {
          if (state is MessageSearchLoading) {
            return const LoadingIndicator();
          } else if (state is MessageSearchSuccess) {
            return state.messages.isEmpty
                ? _buildEmptyResults()
                : _buildSearchResults(state.messages);
          } else if (state is MessageSearchError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('搜索失败: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _startSearch(_searchController.text.trim());
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          } else if (state is MessageSearchEmpty) {
            return _buildEmptyResults();
          }
          return _buildSearchHint();
        },
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '没有找到匹配 "${_searchController.text}" 的消息',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHint() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '输入关键词搜索消息',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Message> messages) {
    return ListView.separated(
      itemCount: messages.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final message = messages[index];
        return InkWell(
          onTap: () {
            // 导航到对应会话并高亮显示该消息
            _navigateToMessage(message);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 会话标题
                if (widget.sessionId == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      '会话: ${message.sessionId}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                
                // 消息内容预览
                ChatMessageItem(
                  message: message,
                  searchHighlight: _searchController.text.trim(),
                ),
                
                // 消息时间
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatTimestamp(message.timestamp),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToMessage(Message message) async {
    // 获取会话信息
    final sessionResult = await context.read<MessageSearchBloc>().getSessionById(message.sessionId);
    sessionResult.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('无法打开消息: ${failure.message}')),
        );
      },
      (session) {
        Navigator.pushNamed(
          context,
          ChatDetailPage.routeName,
          arguments: {
            'session': session,
            'highlightMessageId': message.id,
          },
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 365) {
      return '${timestamp.year}年${timestamp.month}月${timestamp.day}日';
    } else if (difference.inDays > 0) {
      return '${timestamp.month}月${timestamp.day}日';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
} 