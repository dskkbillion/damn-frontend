
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/add_order_delivery_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'order_delivery_event.dart';
part 'order_delivery_state.dart';

/// 订单交付Bloc
@injectable
class OrderDeliveryBloc extends Bloc<OrderDeliveryEvent, OrderDeliveryState> {
  final AddOrderDeliveryUseCase _addOrderDeliveryUseCase;

  /// 构造函数
  OrderDeliveryBloc(this._addOrderDeliveryUseCase) : super(OrderDeliveryInitial()) {
    on<InitOrderDelivery>(_onInitOrderDelivery);
    on<ContentChanged>(_onContentChanged);
    on<AddFile>(_onAddFile);
    on<RemoveFile>(_onRemoveFile);
    on<ClearFiles>(_onClearFiles);
    on<SubmitOrderDelivery>(_onSubmitOrderDelivery);
    on<ResetForm>(_onResetForm);
  }

  /// 初始化订单交付表单
  void _onInitOrderDelivery(
    InitOrderDelivery event,
    Emitter<OrderDeliveryState> emit,
  ) {
    emit(OrderDeliveryFormState(
      orderId: event.orderId,
      content: '',
      files: const [],
    ));
  }

  /// 内容变更
  void _onContentChanged(
    ContentChanged event,
    Emitter<OrderDeliveryState> emit,
  ) {
    if (state is OrderDeliveryFormState) {
      final currentState = state as OrderDeliveryFormState;
      emit(currentState.copyWith(content: event.content));
    }
  }

  /// 添加文件
  void _onAddFile(
    AddFile event,
    Emitter<OrderDeliveryState> emit,
  ) {
    if (state is OrderDeliveryFormState) {
      final currentState = state as OrderDeliveryFormState;
      final updatedFiles = List<String>.from(currentState.files)
        ..add(event.filePath);
      emit(currentState.copyWith(files: updatedFiles));
    }
  }

  /// 移除文件
  void _onRemoveFile(
    RemoveFile event,
    Emitter<OrderDeliveryState> emit,
  ) {
    if (state is OrderDeliveryFormState) {
      final currentState = state as OrderDeliveryFormState;
      final updatedFiles = List<String>.from(currentState.files)
        ..removeAt(event.index);
      emit(currentState.copyWith(files: updatedFiles));
    }
  }

  /// 清空文件
  void _onClearFiles(
    ClearFiles event,
    Emitter<OrderDeliveryState> emit,
  ) {
    if (state is OrderDeliveryFormState) {
      final currentState = state as OrderDeliveryFormState;
      emit(currentState.copyWith(files: const []));
    }
  }

  /// 提交订单交付
  Future<void> _onSubmitOrderDelivery(
    SubmitOrderDelivery event,
    Emitter<OrderDeliveryState> emit,
  ) async {
    if (state is OrderDeliveryFormState) {
      final formState = state as OrderDeliveryFormState;
      
      // 验证表单
      if (formState.content.trim().isEmpty) {
        emit(const OrderDeliveryError('请输入交付内容描述'));
        emit(formState); // 恢复表单状态
        return;
      }
      
      // 显示提交中状态
      emit(OrderDeliverySubmitting());
      
      // 构建参数
      final params = AddOrderDeliveryParams(
        orderId: formState.orderId,
        content: formState.content,
        localFilePaths: formState.files,
      );
      
      // 调用用例
      final result = await _addOrderDeliveryUseCase(params);
      
      // 处理结果
      result.fold(
        (failure) => emit(OrderDeliveryError(failure.message)),
        (success) => emit(OrderDeliverySuccess()),
      );
    }
  }

  /// 重置表单
  void _onResetForm(
    ResetForm event,
    Emitter<OrderDeliveryState> emit,
  ) {
    if (state is OrderDeliveryFormState) {
      final currentState = state as OrderDeliveryFormState;
      emit(OrderDeliveryFormState(
        orderId: currentState.orderId,
        content: '',
        files: const [],
      ));
    } else {
      emit(OrderDeliveryInitial());
    }
  }
} 