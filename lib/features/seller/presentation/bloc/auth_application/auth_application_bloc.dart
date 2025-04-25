import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/submit_authentication_application_usecase.dart';

part 'auth_application_event.dart';
part 'auth_application_state.dart';

/// 认证申请BLoC
@injectable
class AuthApplicationBloc extends Bloc<AuthApplicationEvent, AuthApplicationState> {
  final SubmitAuthenticationApplicationUseCase _submitAuthenticationApplicationUseCase;

  /// 构造函数
  AuthApplicationBloc(this._submitAuthenticationApplicationUseCase) : super(AuthApplicationInitial()) {
    on<SubmitAuthApplication>(_onSubmitAuthApplication);
    on<InitializeAuthApplicationForm>(_onInitializeAuthApplicationForm);
  }
  
  /// 初始化表单
  void _onInitializeAuthApplicationForm(
    InitializeAuthApplicationForm event,
    Emitter<AuthApplicationState> emit,
  ) {
    emit(AuthApplicationFormInitialized(
      authenticationType: event.authenticationType,
      authInfo: event.authInfo,
    ));
  }

  /// 提交认证申请
  Future<void> _onSubmitAuthApplication(
    SubmitAuthApplication event,
    Emitter<AuthApplicationState> emit,
  ) async {
    // 表单验证
    final validationErrors = _validateForm(
      name: event.name,
      identifier: event.identifier,
      filePaths: event.filePaths,
    );
    
    if (validationErrors.isNotEmpty) {
      emit(AuthApplicationValidationError(fieldErrors: validationErrors));
      return;
    }
    
    emit(AuthApplicationSubmitting());

    // 构建应用数据
    final applicationData = AuthenticationApplicationData(
      authenticationId: event.authInfo?.authenticationId ?? 0,
      authenticationType: event.authenticationType.value,
      name: event.name,
      images: '', // 图片URL会在UseCase中处理
      remark: event.description,
      feature: {'id': event.identifier}, // 将标识放入feature字段
    );

    // 调用提交UseCase
    final result = await _submitAuthenticationApplicationUseCase(
      SubmitAuthenticationApplicationParams(
        applicationData: applicationData,
        localFilePaths: event.filePaths,
      ),
    );

    // 处理结果
    result.fold(
      (failure) => emit(AuthApplicationFailure(message: _mapFailureToMessage(failure))),
      (success) => emit(AuthApplicationSuccess()),
    );
  }
  
  /// 验证表单
  Map<String, String> _validateForm({
    required String name,
    required String identifier,
    required List<String> filePaths,
  }) {
    final errors = <String, String>{};
    
    if (name.isEmpty) {
      errors['name'] = '名称不能为空';
    }
    
    if (identifier.isEmpty) {
      errors['identifier'] = '标识不能为空';
    }
    
    if (filePaths.isEmpty) {
      errors['files'] = '请上传至少一个证明文件';
    }
    
    return errors;
  }

  /// 将失败类型映射为错误消息
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return '服务器错误，请稍后再试';
      case NetworkFailure:
        return '网络错误，请检查网络连接';
      case CacheFailure:
        return '缓存错误，请重新提交';
      default:
        return '提交失败，请稍后再试';
    }
  }
} 