import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/after_sales_application.dart';
import '../repositories/i_after_sales_repository.dart';

/// Use case for fetching the details of a specific after-sales application.
@lazySingleton // Register as a singleton instance
class GetAfterSalesDetailUseCase implements UseCase<AfterSalesApplication, GetAfterSalesDetailParams> {
  final IAfterSalesRepository repository;

  GetAfterSalesDetailUseCase(this.repository);

  @override
  Future<Either<Failure, AfterSalesApplication>> call(GetAfterSalesDetailParams params) async {
    // Convert String ID from params to int required by repository
    final int? refundId = int.tryParse(params.id);
    if (refundId == null) {
      // Handle parsing error, maybe return a specific Failure type
      return Left(SimpleFailure('Invalid ID format'));
    }
    return await repository.getAfterSalesDetail(refundId);
  }
}

/// Parameters required for fetching after-sales detail.
class GetAfterSalesDetailParams {
  final String id; // Use String here to match the ID passed from the page

  GetAfterSalesDetailParams({required this.id});

  // No need for Equatable if it's simple like this, unless used in Bloc state comparisons directly
} 