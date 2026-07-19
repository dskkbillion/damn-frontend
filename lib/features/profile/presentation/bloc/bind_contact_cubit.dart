import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';


// --- States ---

abstract class BindContactState extends Equatable {
  const BindContactState();

  @override
  List<Object?> get props => [];
}

class BindContactInitial extends BindContactState {
  const BindContactInitial();
}

class BindContactSendingCode extends BindContactState {
  const BindContactSendingCode();
}

class BindContactCodeSent extends BindContactState {
  const BindContactCodeSent();
}

class BindContactCodeSendFailure extends BindContactState {
  final String message;
  const BindContactCodeSendFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class BindContactBinding extends BindContactState {
  const BindContactBinding();
}

class BindContactSuccess extends BindContactState {
  const BindContactSuccess();
}

class BindContactFailure extends BindContactState {
  final String message;
  const BindContactFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Cubit ---

enum BindContactType { email, phone }

class BindContactCubit extends Cubit<BindContactState> {
  final Dio dio;

  BindContactCubit({required this.dio}) : super(const BindContactInitial());

  /// 发送验证码
  Future<void> sendCode(String contact) async {
    emit(const BindContactSendingCode());

    const String endpoint = '/api/common/send-code/login';
    final Map<String, dynamic> data = {
      'mobile': contact,
    };

    AppLogger.d('[BindContactCubit] 发送验证码（联系方式省略）');
    AppLogger.d('[BindContactCubit] 请求接口: $endpoint');

    try {
      final response = await dio.post(endpoint, data: data);

      if (response.statusCode == 200 &&
          (response.data['code'] == 200 || response.data['code'] == 0)) {
        AppLogger.d('[BindContactCubit] 验证码发送成功');
        emit(const BindContactCodeSent());

        // 60秒后重置为初始状态，允许重新发送
        Future.delayed(const Duration(seconds: 60), () {
          if (state is BindContactCodeSent) {
            emit(const BindContactInitial());
          }
        });
      } else {
        final String errorMsg = response.data['msg'] ?? '发送验证码失败';
        AppLogger.d('[BindContactCubit] 验证码发送失败（服务端消息省略）');
        emit(BindContactCodeSendFailure(errorMsg));
      }
    } on DioException catch (e) {
      AppLogger.d('[BindContactCubit] DIO错误: ${e.type}');
      if (e.response?.data is Map && e.response?.data['msg'] != null) {
        emit(BindContactCodeSendFailure(e.response?.data['msg']));
      } else {
        emit(const BindContactCodeSendFailure('发送验证码失败，请检查网络连接'));
      }
    } catch (e) {
      AppLogger.d('[BindContactCubit] 未知错误: ${e.runtimeType}');
      emit(const BindContactCodeSendFailure('发送验证码失败'));
    }
  }

  /// 绑定联系方式
  Future<void> bind(String contact, String code, BindContactType type) async {
    emit(const BindContactBinding());

    const String endpoint = '/api/member/bind-contact';
    final Map<String, dynamic> data = {
      'contact': contact,
      'code': code,
      'type': type == BindContactType.email ? 'email' : 'phone',
    };

    AppLogger.d('[BindContactCubit] 绑定联系方式: 类型=${type.name}, 值省略');
    AppLogger.d('[BindContactCubit] 请求接口: $endpoint');

    try {
      final response = await dio.post(endpoint, data: data);

      if (response.statusCode == 200 &&
          (response.data['code'] == 200 || response.data['code'] == 0)) {
        AppLogger.d('[BindContactCubit] 绑定成功');
        emit(const BindContactSuccess());
      } else {
        final String errorMsg = response.data['msg'] ?? '绑定失败';
        AppLogger.d('[BindContactCubit] 绑定失败（服务端消息省略）');
        emit(BindContactFailure(errorMsg));
      }
    } on DioException catch (e) {
      AppLogger.d('[BindContactCubit] DIO错误: ${e.type}');
      if (e.response?.data is Map && e.response?.data['msg'] != null) {
        emit(BindContactFailure(e.response?.data['msg']));
      } else {
        emit(const BindContactFailure('绑定失败，请检查网络连接'));
      }
    } catch (e) {
      AppLogger.d('[BindContactCubit] 未知错误: ${e.runtimeType}');
      emit(const BindContactFailure('绑定失败'));
    }
  }
}
