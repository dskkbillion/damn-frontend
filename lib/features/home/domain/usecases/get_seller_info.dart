import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/seller_product.dart';
import 'package:dskk_flutter_refactor/features/home/domain/repositories/seller_products_repository.dart';

class GetSellerInfo {
  final SellerProductsRepository repository;

  GetSellerInfo(this.repository);

  Future<Either<Failure, SellerInfo?>> execute(int sellerId) async {
    return repository.getSellerInfo(sellerId);
  }
} 