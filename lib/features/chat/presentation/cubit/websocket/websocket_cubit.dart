import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_web_socket_data_source.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/chat_web_socket_data_source.impl.dart';

part 'websocket_state.dart';
part 'websocket_cubit.freezed.dart';

/// Cubit for managing WebSocket connection status
class WebSocketCubit extends Cubit<WebSocketState> {
  final IChatWebSocketDataSource _webSocketDataSource;
  StreamSubscription<ConnectionStatus>? _connectionStatusSubscription;

  WebSocketCubit({
    required IChatWebSocketDataSource webSocketDataSource,
  })  : _webSocketDataSource = webSocketDataSource,
        super(const WebSocketState.disconnected()) {
    _connectionStatusSubscription =
        _webSocketDataSource.connectionStatusStream.listen(
      _handleConnectionStatus,
    );
  }

  /// Connect to WebSocket
  Future<void> connect({String? commonUserId, String? token}) async {
    if (state is _Connected || state is _Connecting) return;

    emit(const WebSocketState.connecting());

    try {
      await _webSocketDataSource.connect(
        commonUserId ?? '',
        token ?? '',
      );
    } catch (_) {
      // Connection errors can contain a transport URI. Never surface its raw
      // string because a future transport implementation may include secrets.
      emit(const WebSocketState.error('WebSocket connection error'));
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    await _webSocketDataSource.disconnect();
    emit(const WebSocketState.disconnected());
  }

  void _handleConnectionStatus(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connecting:
        if (state is! _Connecting) {
          emit(const WebSocketState.connecting());
        }
        break;
      case ConnectionStatus.connected:
        if (state is! _Connected) {
          emit(const WebSocketState.connected());
        }
        break;
      case ConnectionStatus.disconnected:
        if (state is! _Disconnected) {
          emit(const WebSocketState.disconnected());
        }
        break;
      case ConnectionStatus.error:
        if (state is! _Error) {
          emit(const WebSocketState.error('WebSocket connection error'));
        }
        break;
    }
  }

  @override
  Future<void> close() {
    _connectionStatusSubscription?.cancel();
    return super.close();
  }
}
