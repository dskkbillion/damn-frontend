import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/features/auth/data/datasources/user_info_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/auth/data/models/user_info_model.dart';
import 'package:dskk_flutter_refactor/features/auth/data/repositories/user_info_repository_impl.dart';

class _HangingNetworkInfo implements NetworkInfo {
  final Completer<bool> probe = Completer<bool>();

  @override
  Future<bool> get isConnected => probe.future;
}

class _StubUserInfoRemoteDataSource implements UserInfoRemoteDataSource {
  int calls = 0;

  @override
  Future<UserInfoModel> fetchUserInfo(String token) async {
    calls++;
    return const UserInfoModel(id: 7);
  }
}

void main() {
  test(
    'continues with the request when the network probe times out',
    () async {
      final networkInfo = _HangingNetworkInfo();
      final remoteDataSource = _StubUserInfoRemoteDataSource();
      final repository = UserInfoRepositoryImpl(
        remoteDataSource: remoteDataSource,
        networkInfo: networkInfo,
        networkProbeTimeout: const Duration(milliseconds: 20),
      );

      final result = await repository.fetchUserInfo('test-token');

      expect(result.isRight(), isTrue);
      expect(remoteDataSource.calls, 1);
    },
  );
}
