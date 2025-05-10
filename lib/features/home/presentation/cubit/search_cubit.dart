import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/home_feed_item.dart';
import '../../domain/usecases/search_products_usecase.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchProductsUsecase searchProductsUsecase;
  
  SearchCubit({required this.searchProductsUsecase}) 
      : super(SearchInitial());

  Future<void> searchProducts(String keyword) async {
    emit(SearchLoading());
    
    final result = await searchProductsUsecase(
      SearchProductsParams(keyword: keyword, page: 1),
    );
    
    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (products) => emit(SearchLoaded(
        products: products, 
        currentPage: 1,
        hasMore: products.length == 20,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> loadMoreProducts(String keyword) async {
    final currentState = state;
    if (currentState is SearchLoaded) {
      emit(SearchLoaded(
        products: currentState.products,
        currentPage: currentState.currentPage,
        hasMore: currentState.hasMore,
        isLoadingMore: true,
      ));
      
      final result = await searchProductsUsecase(
        SearchProductsParams(
          keyword: keyword, 
          page: currentState.currentPage + 1,
        ),
      );
      
      result.fold(
        (failure) => emit(SearchError(message: failure.message)),
        (newProducts) {
          if (newProducts.isEmpty) {
            emit(SearchLoaded(
              products: currentState.products,
              currentPage: currentState.currentPage,
              hasMore: false,
              isLoadingMore: false,
            ));
          } else {
            emit(SearchLoaded(
              products: [...currentState.products, ...newProducts],
              currentPage: currentState.currentPage + 1,
              hasMore: newProducts.length == 20,
              isLoadingMore: false,
            ));
          }
        },
      );
    }
  }
} 