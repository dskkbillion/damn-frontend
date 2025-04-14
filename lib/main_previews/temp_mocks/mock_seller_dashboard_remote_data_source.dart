import 'package:mocktail/mocktail.dart';
import 'package:dskk_flutter_refactor/features/seller_dashboard/data/datasources/seller_dashboard_remote_data_source.dart';
// Import DTOs if your mock needs to return specific types
// import 'package:dskk_flutter_refactor/features/seller_dashboard/data/models/percent_data_dto.dart';
// import 'package:dskk_flutter_refactor/features/seller_dashboard/data/models/upgrade_level_data_dto.dart';
// import 'package:dskk_flutter_refactor/features/seller_dashboard/data/models/index_data_dto.dart';

class MockSellerDashboardRemoteDataSource extends Mock
    implements SellerDashboardRemoteDataSource {}

// You might also want pre-defined DTO instances for testing:
// final tPercentDataDto = PercentDataDto(...);
// final tUpgradeLevelDataDto = UpgradeLevelDataDto(...);
// final tIndexDataDto = IndexDataDto(...); 