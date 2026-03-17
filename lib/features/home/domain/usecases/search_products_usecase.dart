import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/home_feed_item.dart';
import '../repositories/home_repository.dart';

class SearchProductsParams {
  static const int defaultPageSize = 10;
  final String keyword;
  final int page;
  final int pageSize;
  
  SearchProductsParams({
    required this.keyword, 
    this.page = 1, 
    this.pageSize = defaultPageSize,
  });
}

class SearchProductsUsecase implements UseCase<List<HomeFeedItem>, SearchProductsParams> {
  final IHomeRepository repository;

  SearchProductsUsecase(this.repository);

  @override
  Future<Either<Failure, List<HomeFeedItem>>> call(SearchProductsParams params) {
    return repository.searchProducts(
      params.keyword,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
} 
