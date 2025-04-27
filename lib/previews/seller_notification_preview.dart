import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 导入页面和 Bloc
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/notification_list_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/notification_list/notification_list_bloc.dart';

// 导入 Mock 依赖和 UseCases
import 'package:dskk_flutter_refactor/features/seller/mocks/mock_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_notification_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_unread_notification_count_usecase.dart';

// 实例化模拟仓库
final mockSellerRepo = MockSellerRepository();

// 创建 UseCase 实例
final getSellerNotificationListUseCase = GetSellerNotificationListUseCase(mockSellerRepo);
final markNotificationAsReadUseCase = MarkNotificationAsReadUseCase(mockSellerRepo);
final markAllNotificationsAsReadUseCase = MarkAllNotificationsAsReadUseCase(mockSellerRepo);
final getUnreadNotificationCountUseCase = GetUnreadNotificationCountUseCase(mockSellerRepo);

void main() {
  runApp(const SellerNotificationPreviewApp());
}

class SellerNotificationPreviewApp extends StatelessWidget {
  const SellerNotificationPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationListBloc(
        getSellerNotificationListUseCase,
        markNotificationAsReadUseCase,
        markAllNotificationsAsReadUseCase,
        getUnreadNotificationCountUseCase,
      ),
      child: MaterialApp(
        title: 'Notification List Preview',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // TODO: 引入项目主题
        ),
        home: const NotificationListPage(),
      ),
    );
  }
} 