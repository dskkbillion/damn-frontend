import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/home/domain/repositories/seller_products_repository.dart';

class UnfollowSeller {
  final SellerProductsRepository repository;

  UnfollowSeller(this.repository);

  Future<Either<Failure, bool>> execute(int sellerId) {
    return repository.unfollowSeller(sellerId);
  }
} 