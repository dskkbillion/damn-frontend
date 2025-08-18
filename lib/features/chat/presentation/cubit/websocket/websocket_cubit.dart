import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_web_socket_data_source.dart';

part 'websocket_state.dart';
part 'websocket_cubit.freezed.dart';

/// Cubit for managing WebSocket connection status
class WebSocketCubit extends Cubit<WebSocketState> {
  final IChatWebSocketDataSource _webSocketDataSource;
  
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _baseReconnectDelay = Duration(seconds: 2);
  
  WebSocketCubit({
    required IChatWebSocketDataSource webSocketDataSource,
  })  : _webSocketDataSource = webSocketDataSource,
        super(const WebSocketState.disconnected());
  
  /// Connect to WebSocket
  Future<void> connect() async {
    if (state is _Connected || state is _Connecting) return;
    
    emit(const WebSocketState.connecting());
    _reconnectAttempts = 0;
    
    try {
      await _webSocketDataSource.connect();
      emit(const WebSocketState.connected());
      
      // Listen to connection status
      _webSocketDataSource.connectionStatus.listen((isConnected) {
        if (!isConnected && state is _Connected) {
          emit(const WebSocketState.disconnected());
          _scheduleReconnect();
        }
      });
    } catch (e) {
      emit(WebSocketState.error(e.toString()));
      _scheduleReconnect();
    }
  }
  
  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    _cancelReconnectTimer();
    await _webSocketDataSource.disconnect();
    emit(const WebSocketState.disconnected());
  }
  
  /// Reconnect with exponential backoff
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      emit(const WebSocketState.error('Maximum reconnection attempts reached'));
      return;
    }
    
    _cancelReconnectTimer();
    
    // Calculate delay with exponential backoff
    final delay = _baseReconnectDelay * (1 << _reconnectAttempts);
    _reconnectAttempts++;
    
    emit(WebSocketState.reconnecting(
      attempt: _reconnectAttempts,
      maxAttempts: _maxReconnectAttempts,
      nextRetryIn: delay,
    ));
    
    _reconnectTimer = Timer(delay, () async {
      await connect();
    });
  }
  
  /// Cancel reconnect timer
  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
  
  /// Reset reconnection attempts
  void resetReconnectAttempts() {
    _reconnectAttempts = 0;
  }
  
  @override
  Future<void> close() {
    _cancelReconnectTimer();
    _webSocketDataSource.disconnect();
    return super.close();
  }
}