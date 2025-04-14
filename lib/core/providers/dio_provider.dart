import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a singleton instance of [Dio]
final dioProvider = Provider<Dio>((ref) {
  // TODO: Configure Dio options (baseUrl, interceptors, etc.) if needed
  return Dio();
}); 