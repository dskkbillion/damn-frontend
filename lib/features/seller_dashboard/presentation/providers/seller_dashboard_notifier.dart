import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dskk_flutter_refactor/features/seller_dashboard/domain/usecases/get_seller_dashboard_data.dart';
import 'seller_dashboard_state.dart'; // Import the state definition

// Removed the conflicting provider definition from here.
// The provider is now correctly defined in dashboard_providers.dart

class SellerDashboardNotifier extends StateNotifier<SellerDashboardState> {
  final GetSellerDashboardData _getSellerDashboardData;

  SellerDashboardNotifier(this._getSellerDashboardData)
      : super(const SellerDashboardState());

  Future<void> fetchDashboardData() async {
    if (state.status == SellerDashboardStatus.loading) return;

    state = state.copyWith(status: SellerDashboardStatus.loading, clearFailure: true);

    final result = await _getSellerDashboardData();

    result.fold(
      (failure) {
        state = state.copyWith(status: SellerDashboardStatus.failure, failure: failure);
      },
      (data) {
        state = state.copyWith(status: SellerDashboardStatus.success, data: data);
      },
    );
  }

  Future<void> refreshDashboardData() async {
     await fetchDashboardData();
  }
} 