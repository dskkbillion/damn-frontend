part of 'search_cubit.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  
  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<HomeFeedItem> products;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  
  const SearchLoaded({
    required this.products, 
    required this.currentPage,
    required this.hasMore,
    required this.isLoadingMore,
  });
  
  @override
  List<Object> get props => [products, currentPage, hasMore, isLoadingMore];
}

class SearchError extends SearchState {
  final String message;
  
  const SearchError({required this.message});
  
  @override
  List<Object> get props => [message];
} 