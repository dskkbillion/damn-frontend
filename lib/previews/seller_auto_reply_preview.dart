import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import Page and Bloc
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auto_reply_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/auto_reply/auto_reply_bloc.dart';

// Import Mock Dependencies and UseCases
import 'package:dskk_flutter_refactor/features/seller/mocks/mock_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_auto_reply_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/set_auto_reply_usecase.dart';

// Instantiate mock repository
final mockSellerRepo = MockSellerRepository();

// Create UseCase instances
final getAutoReplyUseCase = GetAutoReplyUseCase(mockSellerRepo);
final setAutoReplyUseCase = SetAutoReplyUseCase(mockSellerRepo);

// Create BLoC instance (using .value approach)
final autoReplyBlocInstance = AutoReplyBloc(getAutoReplyUseCase, setAutoReplyUseCase);

void main() {
  runApp(const SellerAutoReplyPreviewApp());
}

class SellerAutoReplyPreviewApp extends StatelessWidget {
  const SellerAutoReplyPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Reply Settings Preview',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // TODO: Introduce project theme
      ),
      home: Builder( // Use Builder for correct context
        builder: (materialAppContext) {
          return BlocProvider.value( // Use BlocProvider.value
            value: autoReplyBlocInstance,
            child: const AutoReplyPage(), // Assuming AutoReplyPage handles initial event dispatch
          );
        },
      ),
    );
  }
} 