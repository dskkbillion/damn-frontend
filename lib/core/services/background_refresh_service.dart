import 'dart:async';
import 'package:flutter/widgets.dart';
import '../utils/app_logger.dart';
import '../../core/storage/secure_storage_repository.dart';
import 'profile_preloader_service.dart';

class BackgroundRefreshService with WidgetsBindingObserver {
  static const Duration _refreshInterval = Duration(minutes: 5);

  final ProfilePreloaderService _preloaderService;
  final ISecureStorageRepository _secureStorage;

  Timer? _timer;

  BackgroundRefreshService({
    required ProfilePreloaderService preloaderService,
    required ISecureStorageRepository secureStorage,
  }) : _preloaderService = preloaderService,
       _secureStorage = secureStorage;

  void init() {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    AppLogger.d('[BackgroundRefresh] Service initialized');
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelTimer();
    AppLogger.d('[BackgroundRefresh] Service disposed');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _startTimer();
        _refreshNow();
        AppLogger.d('[BackgroundRefresh] App resumed, timer restarted');
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _cancelTimer();
        AppLogger.d('[BackgroundRefresh] App paused/inactive, timer cancelled');
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _refreshNow() async {
    final token = await _secureStorage.getToken();
    if (token == null) {
      AppLogger.d('[BackgroundRefresh] User not logged in, skipping refresh');
      return;
    }

    AppLogger.d('[BackgroundRefresh] Refreshing core data...');
    try {
      await _preloaderService.preloadCoreData();
      AppLogger.d('[BackgroundRefresh] Refresh completed');
    } catch (e) {
      AppLogger.d('[BackgroundRefresh] Refresh failed: $e');
    }
  }

  void _startTimer() {
    _cancelTimer();
    _timer = Timer.periodic(_refreshInterval, (_) => _refreshNow());
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
