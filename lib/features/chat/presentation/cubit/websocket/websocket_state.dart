part of 'websocket_cubit.dart';

@freezed
class WebSocketState with _$WebSocketState {
  const factory WebSocketState.disconnected() = _Disconnected;
  
  const factory WebSocketState.connecting() = _Connecting;
  
  const factory WebSocketState.connected() = _Connected;
  
  const factory WebSocketState.reconnecting({
    required int attempt,
    required int maxAttempts,
    required Duration nextRetryIn,
  }) = _Reconnecting;
  
  const factory WebSocketState.error(String message) = _Error;
}