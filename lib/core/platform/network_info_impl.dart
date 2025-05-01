import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dskk_flutter_refactor/core/platform/network_info.dart';
// import 'package:injectable/injectable.dart';

/// DEPRECATED: 这个实现已被 lib/core/network/network_info.dart 中的实现替代
/// Implementation of NetworkInfo using connectivity_plus.
// @LazySingleton(as: NetworkInfo) // Register as LazySingleton for NetworkInfo
// @injectable // Mark class for injectable generator
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  // Inject Connectivity instance
  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    // Check if the result is not none (connected to Wifi or Mobile)
    // Note: ConnectivityResult can have multiple values, adjust if needed
    return connectivityResult.contains(ConnectivityResult.mobile) ||
           connectivityResult.contains(ConnectivityResult.wifi) ||
           connectivityResult.contains(ConnectivityResult.ethernet);
           // Add other connection types if necessary (e.g., bluetooth, vpn)
  }
}
