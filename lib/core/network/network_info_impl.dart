import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

import 'network_info.dart';

@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    // Check if the result is not none
    // Consider adding checks for specific types like wifi/mobile if needed
    return result != ConnectivityResult.none;
  }
}

// We need to tell injectable how to get an instance of Connectivity
// Option 1: Add Connectivity directly if injectable can find it (less common)
// Option 2: Provide it via a module (recommended) 