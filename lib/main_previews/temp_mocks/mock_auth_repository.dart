import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {
  // Helper methods for stubbing
  void arrangeGetTokenSuccess(String token) {
    when(() => getToken()).thenAnswer((_) async => Right(token));
  }

  void arrangeGetTokenFailure(Failure failure) {
    when(() => getToken()).thenAnswer((_) async => Left(failure));
  }
} 