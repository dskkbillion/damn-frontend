import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
// TODO: Import the actual AuthRepository implementation when available
// import 'package:dskk_flutter_refactor/features/auth/data/repositories/auth_repository_impl.dart';

/// Provider for the authentication repository interface.
///
/// This should be overridden in the main DI setup to provide the
/// actual implementation (AuthRepositoryImpl).
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  // By default, this throws an error. It MUST be overridden.
  // In tests or previews, override with MockAuthRepository.
  // In the main app, override with AuthRepositoryImpl.
  throw UnimplementedError('authRepositoryProvider must be overridden');
  // Example override in main: Provider<IAuthRepository>((ref) => AuthRepositoryImpl(...));
  // Example override in preview: Provider<IAuthRepository>((ref) => MockAuthRepository());
}); 