import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory = [];
  List<String> _hotSearches = ['修改待审核', '产品', '设计', '文案']; // 默认热搜词
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _fetchHotKeywords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 从API获取热搜词
  Future<void> _fetchHotKeywords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取API基础URL
      final baseUrl = dotenv.env['BACKEND_BASE_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('BACKEND_BASE_URL environment variable is not set');
      }
      final url = Uri.parse('$baseUrl/api/common/config');

      // 发起请求
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'clienttype': '1',
          'client': 'android',
          'version': '100',
        },
      );

      // 处理响应
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['code'] == 200 && jsonData['data'] != null) {
          final system = jsonData['data']['system'];
          if (system != null && system['hotKeyWord'] != null) {
            final hotKeyWords = _parseHotKeywords(system['hotKeyWord']);
            if (hotKeyWords.isNotEmpty) {
              setState(() {
                _hotSearches = hotKeyWords;
              });
            }
          }
        }
      }
    } catch (e) {
      print('获取热搜词出错: $e');
      // 发生错误时继续使用默认热搜词
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 解析热搜词JSON字符串
  List<String> _parseHotKeywords(String hotKeyWord) {
    try {
      final dynamic parsed = json.decode(hotKeyWord);
      if (parsed is List) {
        return parsed.map((item) => item.toString()).toList();
      }
      return [];
    } catch (e) {
      print('解析热搜词出错: $e');
      return [];
    }
  }

  // 加载搜索历史
  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('search_history') ?? [];
    });
  }

  // 保存搜索历史
  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', _searchHistory);
  }

  // 处理搜索
  void _handleSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    
    setState(() {
      // 移除已有的相同关键词
      _searchHistory.removeWhere((item) => item == keyword);
      // 添加到最前面
      _searchHistory.insert(0, keyword);
      // 限制历史记录数量
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.sublist(0, 10);
      }
    });
    
    // 保存历史记录
    _saveSearchHistory();
    
    // 导航到搜索结果页面
    context.push('/home/search-results?keyword=${Uri.encodeComponent(keyword)}');
  }

  // 清除所有搜索历史
  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
    _saveSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: appLocalizations.home_search_hint,
            border: InputBorder.none,
          ),
          onSubmitted: _handleSearch,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _handleSearch(_searchController.text);
            },
            child: Text(appLocalizations.search_button),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 热门搜索
            Row(
              children: [
                Text(appLocalizations.search_hot_keywords, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (_isLoading)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 16,
                    height: 16,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _hotSearches.map((term) => ActionChip(
                label: Text(term),
                onPressed: () => _handleSearch(term),
              )).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // 搜索历史
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appLocalizations.search_history, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _clearSearchHistory,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.map((term) => InputChip(
                label: Text(term),
                onPressed: () => _handleSearch(term),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _searchHistory.remove(term);
                  });
                  _saveSearchHistory();
                },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
} 