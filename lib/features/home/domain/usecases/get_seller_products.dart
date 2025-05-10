import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/seller_product.dart';
import 'package:dskk_flutter_refactor/features/home/domain/repositories/seller_products_repository.dart';

class GetSellerProducts {
  final SellerProductsRepository repository;

  GetSellerProducts(this.repository);

  Future<Either<Failure, List<SellerProduct>>> execute(int sellerId) {
    return repository.getSellerProducts(sellerId);
  }
} 