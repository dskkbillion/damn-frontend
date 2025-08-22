import 'dart:async';

/// Debouncer utility for delaying function execution
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  /// Execute function after delay, cancelling previous calls
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel pending execution
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose of resources
  void dispose() {
    _timer?.cancel();
  }
}

/// Throttler utility for limiting function execution frequency
class Throttler {
  final Duration interval;
  Timer? _timer;
  bool _isThrottling = false;
  void Function()? _pendingAction;

  Throttler({required this.interval});

  /// Execute function immediately, then ignore calls for interval duration
  void run(void Function() action) {
    if (!_isThrottling) {
      // Execute immediately
      action();
      _isThrottling = true;
      
      // Set timer to reset throttle
      _timer = Timer(interval, () {
        _isThrottling = false;
        
        // Execute pending action if any
        if (_pendingAction != null) {
          final pending = _pendingAction;
          _pendingAction = null;
          run(pending!);
        }
      });
    } else {
      // Store the latest action to execute after throttle period
      _pendingAction = action;
    }
  }

  /// Cancel throttling
  void cancel() {
    _timer?.cancel();
    _isThrottling = false;
    _pendingAction = null;
  }

  /// Dispose of resources
  void dispose() {
    _timer?.cancel();
  }
}

/// Combined debounce and throttle utility for scroll events
class ScrollOptimizer {
  final Debouncer _loadDebouncer;
  final Throttler _uiThrottler;
  
  ScrollOptimizer({
    Duration loadDebounceDelay = const Duration(milliseconds: 300),
    Duration uiThrottleInterval = const Duration(milliseconds: 100),
  }) : _loadDebouncer = Debouncer(delay: loadDebounceDelay),
        _uiThrottler = Throttler(interval: uiThrottleInterval);

  /// Debounce load more action
  void debounceLoadMore(void Function() loadAction) {
    _loadDebouncer.run(loadAction);
  }

  /// Throttle UI updates
  void throttleUIUpdate(void Function() updateAction) {
    _uiThrottler.run(updateAction);
  }

  /// Cancel all pending actions
  void cancelAll() {
    _loadDebouncer.cancel();
    _uiThrottler.cancel();
  }

  /// Dispose of resources
  void dispose() {
    _loadDebouncer.dispose();
    _uiThrottler.dispose();
  }
}