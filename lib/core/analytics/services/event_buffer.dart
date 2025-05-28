import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/analytics_event.dart';
import 'analytics_api_service.dart';

/// 事件缓存服务
/// 负责本地缓存事件和批量上报，优化网络请求性能
@injectable
class EventBuffer {
  final AnalyticsApiService _apiService;
  final SharedPreferences _prefs;
  
  static const String _bufferKey = 'analytics_event_buffer';
  static const int _maxBufferSize = 50; // 最大缓存事件数量
  static const Duration _uploadInterval = Duration(minutes: 5); // 定时上报间隔
  static const Duration _retryDelay = Duration(minutes: 1); // 重试延迟
  
  final List<AnalyticsEvent> _buffer = [];
  Timer? _uploadTimer;
  Timer? _retryTimer;
  bool _isUploading = false;
  
  EventBuffer(this._apiService, this._prefs) {
    _loadCachedEvents();
    _startPeriodicUpload();
  }

  /// 添加事件到缓存
  void addEvent(AnalyticsEvent event) {
    print('[EventBuffer] 添加事件到缓冲区: ${event.businessType}, ID: ${event.businessId}, 路径: ${event.path}');
    _buffer.add(event);
    
    // 如果缓存满了，立即上报
    if (_buffer.length >= _maxBufferSize) {
      print('[EventBuffer] 缓冲区已满 (${_buffer.length}/${_maxBufferSize})，触发即时上报');
      _uploadEvents();
    } else {
      // 否则保存到本地存储
      print('[EventBuffer] 当前缓冲区事件数: ${_buffer.length}/${_maxBufferSize}');
      _saveCachedEvents();
    }
  }

  /// 强制上报所有缓存的事件
  Future<void> flush() async {
    print('[EventBuffer] 手动触发事件上报，当前缓冲区事件数: ${_buffer.length}');
    if (_buffer.isNotEmpty && !_isUploading) {
      await _uploadEvents();
    } else if (_isUploading) {
      print('[EventBuffer] 已有上报正在进行中，跳过本次上报');
    } else if (_buffer.isEmpty) {
      print('[EventBuffer] 缓冲区为空，无需上报');
    }
  }

  /// 开始定时上报
  void _startPeriodicUpload() {
    print('[EventBuffer] 启动定时上报，间隔: ${_uploadInterval.inMinutes}分钟');
    _uploadTimer?.cancel();
    _uploadTimer = Timer.periodic(_uploadInterval, (_) {
      print('[EventBuffer] 定时上报触发，当前缓冲区事件数: ${_buffer.length}');
      if (_buffer.isNotEmpty && !_isUploading) {
        _uploadEvents();
      } else if (_isUploading) {
        print('[EventBuffer] 已有上报正在进行中，跳过本次定时上报');
      } else if (_buffer.isEmpty) {
        print('[EventBuffer] 缓冲区为空，跳过本次定时上报');
      }
    });
  }

  /// 上报事件
  Future<void> _uploadEvents() async {
    if (_buffer.isEmpty || _isUploading) {
      print('[EventBuffer] 不满足上报条件: ${_buffer.isEmpty ? "缓冲区为空" : "已有上报正在进行中"}');
      return;
    }
    
    _isUploading = true;
    final eventsToUpload = List<AnalyticsEvent>.from(_buffer);
    
    try {
      print('[EventBuffer] 开始上报 ${eventsToUpload.length} 个事件');
      print('[EventBuffer] 事件类型分布: ${_getEventTypeDistribution(eventsToUpload)}');
      
      final results = await _apiService.batchRecordEvents(eventsToUpload);
      print('[EventBuffer] 收到上报响应，处理结果...');
      
      // 检查是否有失败的事件
      final failedIndices = <int>[];
      for (int i = 0; i < results.length; i++) {
        final result = results[i];
        
        // 改进的成功判断逻辑
        bool isSuccess = false;
        
        // 情况1: 正常的成功响应 {"code": 200, ...}
        if (result['code'] == 200) {
          isSuccess = true;
        }
        // 情况2: 服务器返回的空响应或空字符串，API服务将其转换为 {'msg': '操作成功', 'code': 200, ...}
        else if (result['msg'] == '操作成功' && (result['code'] == 200 || result['code'] == null)) {
          isSuccess = true;
        }
        // 情况3: 其他表示成功的情况
        else if (result['success'] == true || result['status'] == 'success') {
          isSuccess = true;
        }
        
        if (!isSuccess) {
          failedIndices.add(i);
          final code = result['code'] ?? 'unknown';
          final message = result['msg'] ?? result['message'] ?? '未知错误';
          print('[EventBuffer] 事件上报失败: index=$i, code=$code, message=$message');
        }
      }
      
      if (failedIndices.isEmpty) {
        // 全部成功，清空缓存
        _buffer.clear();
        await _clearCachedEvents();
        print('[EventBuffer] 所有事件上报成功，缓冲区已清空');
      } else {
        // 部分失败，保留失败的事件
        final failedEvents = failedIndices.map((i) => eventsToUpload[i]).toList();
        _buffer.clear();
        _buffer.addAll(failedEvents);
        await _saveCachedEvents();
        
        print('[EventBuffer] ${failedIndices.length}/${eventsToUpload.length} 个事件上报失败，将在 ${_retryDelay.inMinutes} 分钟后重试');
        _scheduleRetry();
      }
    } catch (e) {
      print('[EventBuffer] 事件上报异常: $e');
      // 上报失败，保持原有事件在缓存中
      print('[EventBuffer] 将在 ${_retryDelay.inMinutes} 分钟后重试上报');
      _scheduleRetry();
    } finally {
      _isUploading = false;
    }
  }

  /// 获取事件类型分布情况
  String _getEventTypeDistribution(List<AnalyticsEvent> events) {
    final Map<String, int> typeCount = {};
    for (var event in events) {
      final type = event.businessType;
      typeCount[type] = (typeCount[type] ?? 0) + 1;
    }
    return typeCount.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  /// 安排重试
  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, () {
      if (_buffer.isNotEmpty && !_isUploading) {
        _uploadEvents();
      }
    });
  }

  /// 从本地存储加载缓存的事件
  Future<void> _loadCachedEvents() async {
    try {
      final cachedJson = _prefs.getString(_bufferKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<dynamic> cachedList = jsonDecode(cachedJson);
        final cachedEvents = cachedList
            .map((json) => AnalyticsEvent.fromJson(json as Map<String, dynamic>))
            .toList();
        
        _buffer.addAll(cachedEvents);
        print('[EventBuffer] 加载了 ${cachedEvents.length} 个缓存事件');
        
        // 如果有缓存事件，尝试上报
        if (_buffer.isNotEmpty) {
          Future.delayed(Duration(seconds: 5), () {
            _uploadEvents();
          });
        }
      }
    } catch (e) {
      print('[EventBuffer] 加载缓存事件失败: $e');
      // 清除损坏的缓存
      await _clearCachedEvents();
    }
  }

  /// 保存事件到本地存储
  Future<void> _saveCachedEvents() async {
    try {
      final jsonList = _buffer.map((event) => event.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString(_bufferKey, jsonString);
    } catch (e) {
      print('[EventBuffer] 保存缓存事件失败: $e');
    }
  }

  /// 清除本地缓存
  Future<void> _clearCachedEvents() async {
    try {
      await _prefs.remove(_bufferKey);
    } catch (e) {
      print('[EventBuffer] 清除缓存失败: $e');
    }
  }

  /// 获取当前缓存事件数量
  int get bufferedEventCount => _buffer.length;

  /// 是否正在上报
  bool get isUploading => _isUploading;

  /// 释放资源
  void dispose() {
    _uploadTimer?.cancel();
    _retryTimer?.cancel();
    
    // 同步保存剩余事件（如果有的话）
    if (_buffer.isNotEmpty) {
      _saveCachedEvents();
    }
  }
} 