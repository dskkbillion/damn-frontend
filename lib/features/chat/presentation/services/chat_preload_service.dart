import 'dart:async';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/constants/message_type.dart';

/// Service for preloading chat images to improve performance
class ChatPreloadService {
  static const int _maxPreloadImages = 20; // Maximum number of images to preload
  static const int _preloadBatchSize = 5; // Number of images to preload at once
  static const Duration _preloadDelay = Duration(milliseconds: 500); // Delay between batches
  
  final Set<String> _preloadedUrls = {};
  final Queue<String> _preloadQueue = Queue();
  Timer? _preloadTimer;
  bool _isPreloading = false;
  ConnectivityResult _currentConnectivity = ConnectivityResult.none;
  
  // Memory pressure monitoring
  double _lastMemoryPressure = 0;
  static const double _maxMemoryPressure = 0.8; // Stop preloading at 80% memory usage
  
  ChatPreloadService() {
    _initConnectivityListener();
    _initMemoryPressureListener();
  }
  
  /// Initialize connectivity listener
  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((result) {
      _currentConnectivity = result.first;
      AppLogger.d('[ChatPreload] Connectivity changed: $_currentConnectivity');
      
      // Pause preloading on cellular to save data
      if (_currentConnectivity == ConnectivityResult.mobile) {
        _pausePreloading();
      } else if (_currentConnectivity == ConnectivityResult.wifi) {
        _resumePreloading();
      }
    });
    
    // Get initial connectivity
    Connectivity().checkConnectivity().then((result) {
      _currentConnectivity = result.first;
    });
  }
  
  /// Initialize memory pressure listener
  void _initMemoryPressureListener() {
    // Monitor memory pressure periodically
    Timer.periodic(const Duration(seconds: 5), (_) {
      _checkMemoryPressure();
    });
  }
  
  /// Check current memory pressure
  void _checkMemoryPressure() {
    // Get image cache info
    final imageCache = PaintingBinding.instance.imageCache;
    final currentSize = imageCache.currentSizeBytes;
    final maxSize = imageCache.maximumSizeBytes;
    
    if (maxSize > 0) {
      _lastMemoryPressure = currentSize / maxSize;
      
      if (_lastMemoryPressure > _maxMemoryPressure) {
        AppLogger.d('[ChatPreload] High memory pressure detected: ${(_lastMemoryPressure * 100).toStringAsFixed(1)}%');
        _pausePreloading();
        
        // Clear some cached images if pressure is too high
        if (_lastMemoryPressure > 0.9) {
          imageCache.clear();
          AppLogger.d('[ChatPreload] Evicted image cache due to high memory pressure');
        }
      }
    }
  }
  
  /// Preload chat room avatars
  Future<void> preloadChatRoomAvatars(
    BuildContext context,
    List<ChatRoom> chatRooms,
  ) async {
    if (!_shouldPreload()) return;
    
    AppLogger.d('[ChatPreload] Starting to preload ${chatRooms.length} chat room avatars');
    
    final avatarUrls = <String>[];
    
    for (final room in chatRooms) {
      // Add participant avatars
      if (room.participant1.avatar != null && room.participant1.avatar!.isNotEmpty) {
        avatarUrls.add(room.participant1.avatar!);
      }
      if (room.participant2.avatar != null && room.participant2.avatar!.isNotEmpty) {
        avatarUrls.add(room.participant2.avatar!);
      }
      
      // Limit the number of avatars to preload
      if (avatarUrls.length >= _maxPreloadImages) break;
    }
    
    await _preloadImages(context, avatarUrls, isAvatar: true);
  }
  
  /// Preload message images for a chat
  Future<void> preloadMessageImages(
    BuildContext context,
    List<ChatMessage> messages,
  ) async {
    if (!_shouldPreload()) return;
    
    final imageUrls = <String>[];
    
    for (final message in messages) {
      if (message.type == ChatMessageType.image && message.context.isNotEmpty) {
        // Parse image URL from context
        final imageUrl = _parseImageUrl(message.context);
        if (imageUrl != null && !_preloadedUrls.contains(imageUrl)) {
          imageUrls.add(imageUrl);
        }
      }
      
      // Limit the number of images to preload
      if (imageUrls.length >= _maxPreloadImages) break;
    }
    
    if (imageUrls.isNotEmpty) {
      AppLogger.d('[ChatPreload] Queuing ${imageUrls.length} message images for preload');
      await _preloadImages(context, imageUrls);
    }
  }
  
  /// Preload images in batches
  Future<void> _preloadImages(
    BuildContext context,
    List<String> imageUrls, {
    bool isAvatar = false,
  }) async {
    if (!context.mounted) return;
    
    // Add URLs to queue
    for (final url in imageUrls) {
      if (!_preloadedUrls.contains(url) && !_preloadQueue.contains(url)) {
        _preloadQueue.add(url);
      }
    }
    
    // Start preloading if not already running
    if (!_isPreloading) {
      _startPreloadingFromQueue(context, isAvatar: isAvatar);
    }
  }
  
  /// Start preloading images from queue
  void _startPreloadingFromQueue(BuildContext context, {bool isAvatar = false}) {
    if (_isPreloading || !_shouldPreload()) return;
    
    _isPreloading = true;
    
    _preloadTimer = Timer.periodic(_preloadDelay, (_) async {
      if (!context.mounted || _preloadQueue.isEmpty || !_shouldPreload()) {
        _stopPreloading();
        return;
      }
      
      // Process a batch of images
      final batch = <String>[];
      for (int i = 0; i < _preloadBatchSize && _preloadQueue.isNotEmpty; i++) {
        batch.add(_preloadQueue.removeFirst());
      }
      
      if (batch.isNotEmpty) {
        await _preloadBatch(context, batch, isAvatar: isAvatar);
      }
    });
  }
  
  /// Preload a batch of images
  Future<void> _preloadBatch(
    BuildContext context,
    List<String> urls, {
    bool isAvatar = false,
  }) async {
    if (!context.mounted) return;
    
    final futures = <Future>[];
    
    for (final url in urls) {
      if (_preloadedUrls.contains(url)) continue;
      
      final future = _preloadSingleImage(context, url, isAvatar: isAvatar);
      futures.add(future);
    }
    
    if (futures.isNotEmpty) {
      await Future.wait(futures, eagerError: false);
      AppLogger.d('[ChatPreload] Preloaded batch of ${futures.length} images');
    }
  }
  
  /// Preload a single image
  Future<void> _preloadSingleImage(
    BuildContext context,
    String url, {
    bool isAvatar = false,
  }) async {
    try {
      if (!context.mounted) return;
      
      final imageProvider = CachedNetworkImageProvider(
        url,
        maxWidth: isAvatar ? 144 : 800, // Smaller size for avatars
        maxHeight: isAvatar ? 144 : 800,
      );
      
      await precacheImage(
        imageProvider,
        context,
        onError: (exception, stackTrace) {
          AppLogger.d('[ChatPreload] Failed to preload image: $url');
        },
      );
      
      _preloadedUrls.add(url);
    } catch (e) {
      AppLogger.d('[ChatPreload] Error preloading image $url: $e');
    }
  }
  
  /// Parse image URL from message context
  String? _parseImageUrl(String context) {
    try {
      // Simple extraction - assumes context is the URL
      // In production, parse JSON if context is structured
      return context.trim();
    } catch (e) {
      return null;
    }
  }
  
  /// Check if preloading should be performed
  bool _shouldPreload() {
    // Don't preload on cellular or when memory pressure is high
    return _currentConnectivity == ConnectivityResult.wifi &&
           _lastMemoryPressure < _maxMemoryPressure;
  }
  
  /// Pause preloading
  void _pausePreloading() {
    AppLogger.d('[ChatPreload] Pausing preload');
    _stopPreloading();
  }
  
  /// Resume preloading
  void _resumePreloading() {
    AppLogger.d('[ChatPreload] Resuming preload');
    // Preloading will resume when new images are added to queue
  }
  
  /// Stop preloading
  void _stopPreloading() {
    _preloadTimer?.cancel();
    _preloadTimer = null;
    _isPreloading = false;
  }
  
  /// Clear preloaded URLs cache
  void clearCache() {
    _preloadedUrls.clear();
    _preloadQueue.clear();
    _stopPreloading();
    AppLogger.d('[ChatPreload] Cache cleared');
  }
  
  /// Dispose of resources
  void dispose() {
    _stopPreloading();
  }
}