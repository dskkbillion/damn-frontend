import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/i_cart_repository.dart';

/// 启动结算流程
class ProceedToCheckoutUseCase implements UseCase<CheckoutPreview, CheckoutRequestData> {
  final ICartRepository repository;

  ProceedToCheckoutUseCase(this.repository);

  @override
  Future<Either<Failure, CheckoutPreview>> call(CheckoutRequestData params) async {
    return await repository.initiateCheckout(params);
  }
}