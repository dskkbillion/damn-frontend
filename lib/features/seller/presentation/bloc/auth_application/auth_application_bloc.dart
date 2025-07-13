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
      // 使用已有认证ID或新的认证ID
      authenticationId: event.authInfo?.authenticationId ?? 
        _getAuthenticationIdByType(event.authenticationType),
      // 使用API需要的类型值
      authenticationType: event.authenticationType.value,
      // 根据认证类型决定是否包含name
      name: event.authenticationType == AuthenticationType.company ? event.name : null,
      // 构建逗号分隔的图片路径
      images: event.filePaths.join(','),
      // 根据认证类型决定是否包含remark
      remark: event.authenticationType == AuthenticationType.education ? event.description : null,
      // 构建feature对象
      feature: {
        'id': event.identifier,
        'description': event.description,
      },
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
  
  /// 根据认证类型获取认证ID
  int _getAuthenticationIdByType(AuthenticationType type) {
    switch (type) {
      case AuthenticationType.idCard:
        return 1; // 实名认证ID
      case AuthenticationType.education:
        return 2; // 学校认证ID
      case AuthenticationType.company:
        return 3; // 公司认证ID
      default:
        return 4; // 其他认证ID
    }
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
    // 修复：增强错误消息处理，特别处理认证相关的特定错误
    if (failure is ServerFailure) {
      final message = failure.message ?? '';
      
      // 检查是否是重复提交错误
      if (message.contains('该认证信息已有待审核或已审核通过') || 
          message.contains('不可再次提交申请')) {
        return '该认证已提交审核，请勿重复申请。如需查看状态，请返回认证管理页面';
      }
      
      // 检查其他常见错误
      if (message.contains('认证信息不完整')) {
        return '认证信息不完整，请检查必填项是否填写正确';
      }
      
      if (message.contains('文件格式不支持')) {
        return '上传的文件格式不支持，请选择图片文件';
      }
      
      if (message.contains('文件大小超限')) {
        return '上传的文件过大，请选择较小的图片文件';
      }
      
      // 如果有具体的服务器错误消息，返回该消息
      if (message.isNotEmpty) {
        return message;
      }
      
      return '服务器错误，请稍后再试';
    }
    
    switch (failure.runtimeType) {
      case NetworkFailure:
        return '网络错误，请检查网络连接';
      case CacheFailure:
        return '缓存错误，请重新提交';
      default:
        return '提交失败，请稍后再试';
    }
  }
} 