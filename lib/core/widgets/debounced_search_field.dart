import 'package:flutter/material.dart';
import '../utils/debouncer.dart';

/// 带防抖功能的搜索输入框
class DebouncedSearchField extends StatefulWidget {
  /// 搜索回调函数
  final Function(String) onSearch;
  
  /// 输入变化回调（用于实时搜索建议）
  final Function(String)? onChanged;
  
  /// 提示文字
  final String? hintText;
  
  /// 防抖延迟时间
  final Duration debounceDelay;
  
  /// 最小搜索长度
  final int minSearchLength;
  
  /// 控制器
  final TextEditingController? controller;
  
  /// 是否自动聚焦
  final bool autofocus;
  
  /// 输入框装饰
  final InputDecoration? decoration;
  
  /// 文字样式
  final TextStyle? style;

  const DebouncedSearchField({
    Key? key,
    required this.onSearch,
    this.onChanged,
    this.hintText,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.minSearchLength = 1,
    this.controller,
    this.autofocus = false,
    this.decoration,
    this.style,
  }) : super(key: key);

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  late TextEditingController _controller;
  late Debouncer _searchDebouncer;
  late Debouncer _changeDebouncer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    
    // 创建防抖器
    _searchDebouncer = Debouncer(delay: widget.debounceDelay);
    _changeDebouncer = Debouncer(delay: const Duration(milliseconds: 100));
    
    // 监听输入变化
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    _searchDebouncer.dispose();
    _changeDebouncer.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text.trim();
    
    // 实时变化回调（短防抖）
    if (widget.onChanged != null) {
      _changeDebouncer.run(() {
        widget.onChanged!(text);
      });
    }
    
    // 搜索回调（长防抖）
    if (text.length >= widget.minSearchLength) {
      _searchDebouncer.run(() {
        widget.onSearch(text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      style: widget.style,
      decoration: widget.decoration ?? InputDecoration(
        hintText: widget.hintText ?? '搜索...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty 
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                _searchDebouncer.cancel();
                _changeDebouncer.cancel();
              },
            )
          : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onSubmitted: (value) {
        // 立即搜索，不等防抖
        final text = value.trim();
        if (text.length >= widget.minSearchLength) {
          _searchDebouncer.cancel();
          widget.onSearch(text);
        }
      },
    );
  }
}

/// 带搜索建议的防抖搜索框
class DebouncedSearchFieldWithSuggestions<T> extends StatefulWidget {
  /// 搜索建议获取函数
  final Future<List<T>> Function(String) onGetSuggestions;
  
  /// 搜索执行函数
  final Function(String) onSearch;
  
  /// 建议项构建器
  final Widget Function(BuildContext, T) suggestionBuilder;
  
  /// 建议项选择回调
  final Function(T)? onSuggestionSelected;
  
  /// 其他配置参数
  final String? hintText;
  final Duration debounceDelay;
  final int minSearchLength;
  final TextEditingController? controller;
  final bool autofocus;
  final int maxSuggestions;

  const DebouncedSearchFieldWithSuggestions({
    Key? key,
    required this.onGetSuggestions,
    required this.onSearch,
    required this.suggestionBuilder,
    this.onSuggestionSelected,
    this.hintText,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.minSearchLength = 1,
    this.controller,
    this.autofocus = false,
    this.maxSuggestions = 5,
  }) : super(key: key);

  @override
  State<DebouncedSearchFieldWithSuggestions<T>> createState() => 
      _DebouncedSearchFieldWithSuggestionsState<T>();
}

class _DebouncedSearchFieldWithSuggestionsState<T> 
    extends State<DebouncedSearchFieldWithSuggestions<T>> {
  late TextEditingController _controller;
  late AsyncDebouncer<List<T>> _suggestionDebouncer;
  
  List<T> _suggestions = [];
  bool _isLoadingSuggestions = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _suggestionDebouncer = AsyncDebouncer<List<T>>(delay: widget.debounceDelay);
    
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    _suggestionDebouncer.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text.trim();
    
    if (text.length >= widget.minSearchLength) {
      setState(() {
        _isLoadingSuggestions = true;
        _showSuggestions = true;
      });
      
      _suggestionDebouncer.run(() => widget.onGetSuggestions(text))
        .then((suggestions) {
          if (mounted) {
            setState(() {
              _suggestions = suggestions.take(widget.maxSuggestions).toList();
              _isLoadingSuggestions = false;
            });
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _suggestions = [];
              _isLoadingSuggestions = false;
            });
          }
        });
    } else {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isLoadingSuggestions = false;
      });
    }
  }

  void _selectSuggestion(T suggestion) {
    setState(() {
      _showSuggestions = false;
    });
    
    if (widget.onSuggestionSelected != null) {
      widget.onSuggestionSelected!(suggestion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 搜索输入框
        DebouncedSearchField(
          controller: _controller,
          onSearch: widget.onSearch,
          hintText: widget.hintText,
          debounceDelay: widget.debounceDelay,
          minSearchLength: widget.minSearchLength,
          autofocus: widget.autofocus,
          onChanged: (_) {
            // 当输入变化时，如果没有建议就隐藏建议框
            if (_suggestions.isEmpty && !_isLoadingSuggestions) {
              setState(() {
                _showSuggestions = false;
              });
            }
          },
        ),
        
        // 搜索建议列表
        if (_showSuggestions) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _isLoadingSuggestions
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : _suggestions.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '暂无搜索建议',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _suggestions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return InkWell(
                        onTap: () => _selectSuggestion(suggestion),
                        child: widget.suggestionBuilder(context, suggestion),
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }
}