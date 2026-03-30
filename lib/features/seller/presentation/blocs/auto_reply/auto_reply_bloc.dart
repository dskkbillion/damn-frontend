import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/auto_reply_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_auto_reply_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/set_auto_reply_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';

part 'auto_reply_event.dart';
part 'auto_reply_state.dart';

/// 自动回复Bloc
@injectable
class AutoReplyBloc extends Bloc<AutoReplyEvent, AutoReplyState> {
  final GetAutoReplyUseCase _getAutoReplyUseCase;
  final SetAutoReplyUseCase _setAutoReplyUseCase;

  /// 构造函数
  AutoReplyBloc(
    this._getAutoReplyUseCase,
    this._setAutoReplyUseCase,
  ) : super(AutoReplyInitial()) {
    on<LoadAutoReplySettings>(_onLoadAutoReplySettings);
    on<UpdateAutoReplyEnabled>(_onUpdateAutoReplyEnabled);
    on<UpdateAutoReplyContent>(_onUpdateAutoReplyContent);
  }

  /// 加载自动回复设置
  Future<void> _onLoadAutoReplySettings(
    LoadAutoReplySettings event,
    Emitter<AutoReplyState> emit,
  ) async {
    emit(AutoReplyLoading());

    final result = await _getAutoReplyUseCase(NoParams());

    emit(result.fold(
      (failure) => AutoReplyError(failure.message),
      (settings) => AutoReplyLoaded(settings),
    ));
  }

  /// 更新自动回复启用状态
  Future<void> _onUpdateAutoReplyEnabled(
    UpdateAutoReplyEnabled event,
    Emitter<AutoReplyState> emit,
  ) async {
    // 确保当前状态为已加载状态
    if (state is! AutoReplyLoaded) {
      return;
    }

    final currentState = state as AutoReplyLoaded;
    final currentSettings = currentState.settings;

    // 如果状态相同，不执行更新
    if (currentSettings.isEnabled == event.isEnabled) {
      return;
    }

    // 显示更新中状态
    emit(AutoReplyUpdating(
      AutoReplySettings(
        isEnabled: event.isEnabled,
        content: currentSettings.content,
      ),
    ));

    // 构建更新参数
    final params = SetAutoReplyParams(
      settings: AutoReplySettings(
        isEnabled: event.isEnabled,
        content: currentSettings.content,
      ),
    );

    // 调用更新用例
    final result = await _setAutoReplyUseCase(params);

    result.fold(
      (failure) => emit(AutoReplyError(failure.message, previousSettings: currentSettings)),
      (success) {
        final savedSettings = AutoReplySettings(
          isEnabled: event.isEnabled,
          content: currentSettings.content,
        );
        emit(AutoReplySaveSuccess(savedSettings));
        emit(AutoReplyLoaded(savedSettings));
      },
    );
  }

  /// 更新自动回复内容
  Future<void> _onUpdateAutoReplyContent(
    UpdateAutoReplyContent event,
    Emitter<AutoReplyState> emit,
  ) async {
    // 确保当前状态为已加载状态或错误状态（带有 previousSettings）
    AutoReplySettings? currentSettings;
    if (state is AutoReplyLoaded) {
      currentSettings = (state as AutoReplyLoaded).settings;
    } else if (state is AutoReplyError && (state as AutoReplyError).previousSettings != null) {
      currentSettings = (state as AutoReplyError).previousSettings;
    } else {
      return;
    }

    final settings = currentSettings!;

    // 显示更新中状态
    emit(AutoReplyUpdating(
      AutoReplySettings(
        isEnabled: settings.isEnabled,
        content: event.content,
      ),
    ));

    // 构建更新参数
    final params = SetAutoReplyParams(
      settings: AutoReplySettings(
        isEnabled: settings.isEnabled,
        content: event.content,
      ),
    );

    // 调用更新用例
    final result = await _setAutoReplyUseCase(params);

    result.fold(
      (failure) => emit(AutoReplyError(failure.message, previousSettings: settings)),
      (success) {
        final savedSettings = AutoReplySettings(
          isEnabled: settings.isEnabled,
          content: event.content,
        );
        emit(AutoReplySaveSuccess(savedSettings));
        emit(AutoReplyLoaded(savedSettings));
      },
    );
  }
} 