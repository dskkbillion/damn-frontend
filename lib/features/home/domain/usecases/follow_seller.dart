import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/home/domain/repositories/seller_products_repository.dart';

class FollowSeller {
  final SellerProductsRepository repository;

  FollowSeller(this.repository);

  Future<Either<Failure, bool>> execute(int sellerId) {
    return repository.followSeller(sellerId);
  }
} 