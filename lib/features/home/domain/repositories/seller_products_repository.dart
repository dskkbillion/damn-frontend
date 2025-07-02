import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/seller_product.dart';

abstract class SellerProductsRepository {
  Future<Either<Failure, List<SellerProduct>>> getSellerProducts(int sellerId);
  Future<Either<Failure, bool>> followSeller(int sellerId);
  Future<Either<Failure, bool>> unfollowSeller(int sellerId);
  Future<Either<Failure, SellerInfo?>> getSellerInfo(int sellerId);
} 