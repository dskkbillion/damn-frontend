import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Module for registering third-party dependencies that injectable cannot handle automatically.
@module
abstract class RegisterModule {
  // Register FlutterSecureStorage as a lazy singleton
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  // Register Connectivity as a lazy singleton
  @lazySingleton
  Connectivity get connectivity => Connectivity();
}
