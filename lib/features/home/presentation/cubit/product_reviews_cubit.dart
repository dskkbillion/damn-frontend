import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_product_reviews_use_case.dart';
import 'product_reviews_state.dart';

@injectable
class ProductReviewsCubit extends Cubit<ProductReviewsState> {
  final GetProductReviewsUseCase _getProductReviewsUseCase;

  ProductReviewsCubit(this._getProductReviewsUseCase)
      : super(ProductReviewsInitial());

  Future<void> getProductReviews(int productId) async {
    emit(ProductReviewsLoading());

    final result = await _getProductReviewsUseCase(
      GetProductReviewsParams(productId: productId),
    );

    emit(result.fold(
      (failure) => ProductReviewsError(message: failure.toString()),
      (reviewsResponse) => ProductReviewsLoaded(
        total: reviewsResponse.total,
        reviews: reviewsResponse.reviews,
      ),
    ));
  }
} 