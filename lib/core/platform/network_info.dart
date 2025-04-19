/// Abstract class to check network connectivity.
abstract class NetworkInfo {
  /// Returns true if the device is currently connected to the network,
  /// false otherwise.
  Future<bool> get isConnected;
}
