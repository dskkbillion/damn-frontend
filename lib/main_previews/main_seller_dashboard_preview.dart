import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
// Import the actual provider definitions
import 'package:dskk_flutter_refactor/features/seller_dashboard/presentation/providers/dashboard_providers.dart';
import 'package:dskk_flutter_refactor/features/seller_dashboard/data/datasources/seller_dashboard_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/seller_dashboard/data/models/index_data_dto.dart';
import 'package:dskk_flutter_refactor/features/seller_dashboard/data/models/percent_data_dto.dart';
import 'package:dskk_flutter_refactor/features/seller_dashboard/data/models/upgrade_level_data_dto.dart';
import 'package:dskk_flutter_refactor/features/seller_dashboard/presentation/pages/seller_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart'; // Ensure mocktail is imported

// Import Mocks
// TODO: TEMPORARY WORKAROUND for stubborn build path error.
// Mocks copied from test/ to lib/main_previews/temp_mocks/ to force build system recognition.
// Remove this workaround once the root cause of the path issue is resolved.
import 'temp_mocks/mock_auth_repository.dart';
import 'temp_mocks/mock_seller_dashboard_remote_data_source.dart';
// Import the notifier provider if it's defined elsewhere
// import 'package:dskk_flutter_refactor/features/seller_dashboard/presentation/providers/seller_dashboard_notifier.dart';
// Import the assumed core auth provider definition
import 'package:dskk_flutter_refactor/features/auth/presentation/providers/auth_providers.dart'; // Corrected import


// --- Create Mock Data Instances ---
// TODO: Populate with realistic mock data
const tPercentDataDto = PercentDataDto(
  heatPercent: 75,
  recoverPercent: 95,
  completePercent: 100,
  goodPercent: 98,
);
const tUpgradeLevelDataDto = UpgradeLevelDataDto(
  days: 100,
  orderNum: 1000,
  orderPrice: 10000,
  totalDays: 211,
  totalOrderNum: 17,
  totalOrderPrice: 2280,
);
const tIndexDataDto = IndexDataDto(
  totalEarnings: 22800,
  thisMonthTotalEarnings: 18800,
  totalOrderNum: 17,
  activeOrderNum: 41,
  pendingOrderNum: 24,
  receiptOrderNum: 17,
  earlyTime: 0,
  latenessTime: 0,
);

// --- Mock Instances --- (Initialize in main)
late MockAuthRepository mockAuthRepository;
late MockSellerDashboardRemoteDataSource mockRemoteDataSource;

void main() {
  // 1. Initialize Mocks
  mockAuthRepository = MockAuthRepository();
  mockRemoteDataSource = MockSellerDashboardRemoteDataSource();

  // 2. Stub Mock Behaviors (Success Case)
  mockAuthRepository.arrangeGetTokenSuccess("fake-preview-token");

  when(() => mockRemoteDataSource.getPercentData(token: any(named: 'token')))
      .thenAnswer((_) async => tPercentDataDto);
  when(() => mockRemoteDataSource.getUpgradeLevelData(token: any(named: 'token')))
      .thenAnswer((_) async => tUpgradeLevelDataDto);
  when(() => mockRemoteDataSource.getIndexData(token: any(named: 'token')))
      .thenAnswer((_) async => tIndexDataDto);

  // Optional: Stub failure cases for testing error UI
  // ... (stubbing for errors as before)

  runApp(ProviderScope(
    overrides: [
      // Override the dependencies that need to be mocked
      authRepositoryProvider.overrideWithValue(mockAuthRepository),
      sellerDashboardRemoteDataSourceProvider.overrideWithValue(mockRemoteDataSource),

      // IMPORTANT: No need to override sellerDashboardRepositoryProvider,
      // getSellerDashboardDataProvider, or sellerDashboardNotifierProvider here.
      // Riverpod will automatically use the overridden dependencies above
      // when creating instances of the real Repository, UseCase, and Notifier.
    ],
    child: const SellerDashboardPreviewApp(),
  ));
}

class SellerDashboardPreviewApp extends StatelessWidget {
  const SellerDashboardPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seller Dashboard Preview',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SellerDashboardPage(),
    );
  }
} 