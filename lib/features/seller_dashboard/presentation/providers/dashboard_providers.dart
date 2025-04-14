import 'package:dskk_flutter_refactor/core/providers/dio_provider.dart'; // Corrected import
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart'; // Corrected import
import 'package:dskk_flutter_refactor/features/auth/presentation/providers/auth_providers.dart'; // Corrected import
import 'package:dskk_flutter_refactor/features/seller_dashboard/data/datasources/seller_dashboard_remote_data_source.dart'; // Corrected import
import 'package:dskk_flutter_refactor/features/seller_dashboard/data/repositories/seller_dashboard_repository_impl.dart'; // Corrected import
import 'package:dskk_flutter_refactor/features/seller_dashboard/domain/repositories/seller_dashboard_repository.dart'; // Corrected import
import 'package:dskk_flutter_refactor/features/seller_dashboard/domain/usecases/get_seller_dashboard_data.dart'; // Corrected import
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the State and Notifier definitions
import 'seller_dashboard_state.dart';
import 'seller_dashboard_notifier.dart';

// Provider for the data source
final sellerDashboardRemoteDataSourceProvider =
    Provider<SellerDashboardRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return SellerDashboardRemoteDataSourceImpl(client: dio);
});

// Provider for the repository
final sellerDashboardRepositoryProvider = Provider<ISellerDashboardRepository>((ref) {
  final remoteDataSource = ref.watch(sellerDashboardRemoteDataSourceProvider);
  final authRepository = ref.watch(authRepositoryProvider); // Use the imported authRepositoryProvider
  return SellerDashboardRepositoryImpl(
    remoteDataSource: remoteDataSource,
    authRepository: authRepository,
  );
});

// Provider for the use case
final getSellerDashboardDataProvider = Provider<GetSellerDashboardData>((ref) {
  final repository = ref.watch(sellerDashboardRepositoryProvider);
  return GetSellerDashboardDataImpl(repository);
});

// Provider for the StateNotifier
final sellerDashboardNotifierProvider = StateNotifierProvider<SellerDashboardNotifier, SellerDashboardState>((ref) {
  // Watch the use case provider
  final getDashboardDataUseCase = ref.watch(getSellerDashboardDataProvider);
  // Pass the use case instance to the Notifier constructor
  return SellerDashboardNotifier(getDashboardDataUseCase);
});

// TODO: Define sellerDashboardNotifierProvider here or in a separate notifier file
// Example:
// final sellerDashboardNotifierProvider = StateNotifierProvider<SellerDashboardNotifier, SellerDashboardState>((ref) {
//   final getDashboardData = ref.watch(getSellerDashboardDataProvider);
//   return SellerDashboardNotifier(getDashboardData);
// }); 