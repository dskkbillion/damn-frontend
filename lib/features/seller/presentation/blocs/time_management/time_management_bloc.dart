import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/time_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_time_settings_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/update_time_settings_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/core/events/event_bus.dart';

part 'time_management_event.dart';
part 'time_management_state.dart';

/// 卖家时间管理Bloc
@injectable
class TimeManagementBloc extends Bloc<TimeManagementEvent, TimeManagementState> {
  final GetTimeSettingsUseCase _getTimeSettingsUseCase;
  final UpdateTimeSettingsUseCase _updateTimeSettingsUseCase;

  /// 构造函数
  TimeManagementBloc(
    this._getTimeSettingsUseCase,
    this._updateTimeSettingsUseCase,
  ) : super(TimeManagementInitial()) {
    on<LoadTimeSettings>(_onLoadTimeSettings);
    on<UpdateOnlineStatus>(_onUpdateOnlineStatus);
  }

  /// 加载时间设置
  Future<void> _onLoadTimeSettings(
    LoadTimeSettings event,
    Emitter<TimeManagementState> emit,
  ) async {
    emit(TimeManagementLoading());

    final result = await _getTimeSettingsUseCase(NoParams());

    emit(result.fold(
      (failure) => TimeManagementError(failure.message),
      (settings) => TimeManagementLoaded(settings),
    ));
  }

  /// 更新在线状态
  Future<void> _onUpdateOnlineStatus(
    UpdateOnlineStatus event,
    Emitter<TimeManagementState> emit,
  ) async {
    // 确保当前状态为已加载状态
    if (state is! TimeManagementLoaded) {
      return;
    }

    final currentState = state as TimeManagementLoaded;
    final currentSettings = currentState.settings;

    // 如果状态相同，不执行更新
    if (currentSettings.isOnline == event.isOnline) {
      return;
    }

    // 显示更新中状态
    emit(TimeManagementUpdating(
      TimeSettings(
        isOnline: event.isOnline,
        availableTimeSlots: currentSettings.availableTimeSlots,
      ),
    ));

    // 构建更新参数
    final params = UpdateTimeSettingsParams(
      settings: TimeSettingsData(
        isOnline: event.isOnline,
      ),
    );

    // 调用更新用例
    final result = await _updateTimeSettingsUseCase(params);

    result.fold(
      (failure) => emit(TimeManagementError(failure.message)),
      (success) {
        // 通过事件总线通知其他页面（如卖家主页）在线状态已变更
        EventBus().fireSellerOnlineStatusChangedEvent(
          SellerOnlineStatusChangedEvent(isOnline: event.isOnline),
        );
        // 更新成功后重新获取时间设置
        add(LoadTimeSettings());
      },
    );
  }
} 