import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/product_detail.dart';
import '../../domain/entities/product_translation.dart';
import '../../domain/repositories/home_repository.dart';

part 'product_detail_state.dart';

@injectable
class ProductDetailCubit extends Cubit<ProductDetailState> {
  final IHomeRepository repository;

  ProductDetailCubit(this.repository) : super(ProductDetailInitial());

  Future<void> getProductDetail(String productId) async {
    emit(ProductDetailLoading());
    final result = await repository.getProductDetail(productId);

    emit(result.fold(
      (failure) => ProductDetailError(failure.message),
      (record) => ProductDetailLoaded(record.$1, translation: record.$2),
    ));
  }
} 