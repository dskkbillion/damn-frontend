import 'interaction_state.dart';
import 'next_action.dart';

export 'dasn_format_exception.dart';
export 'interaction_state.dart';
export 'next_action.dart';

/// The small, transport-neutral projection consumed by an Agent workbench or
/// trusted client.  It intentionally does not model credits, orders, payment,
/// or delivery facts.
class TaskProjection {
  const TaskProjection({
    required this.taskLifecycle,
    required this.responsibilityAction,
    required this.syncStatus,
    this.waitingOn = WaitingOn.none,
    this.nextActions = const <NextAction>[],
  });

  final TaskLifecycle taskLifecycle;
  final ResponsibilityAction responsibilityAction;
  final SyncStatus syncStatus;
  final WaitingOn waitingOn;
  final List<NextAction> nextActions;

  bool get hasPendingResponsibilityAction =>
      responsibilityAction == ResponsibilityAction.pending;

  /// Parses the CORE_P0 `TaskProjection` shape.
  ///
  /// `taskLifecycle`, `responsibilityAction`, and `syncStatus` are required by
  /// the wire schema.  Missing, null, or non-string values fail immediately;
  /// this prevents a partially decoded projection from driving a button.
  /// Unknown non-empty enum values are retained as the corresponding
  /// fail-closed `unknown` value.
  factory TaskProjection.fromJson(Map<String, dynamic> json) {
    final taskLifecycle = _requiredString(json, 'taskLifecycle');
    final responsibilityAction = _requiredString(json, 'responsibilityAction');
    final syncStatus = _requiredString(json, 'syncStatus');

    final waitingOnValue = json['waitingOn'];
    if (json.containsKey('waitingOn') && waitingOnValue == null) {
      throw DasnProjectionFormatException(
        'TaskProjection.waitingOn must not be null when present',
        waitingOnValue,
      );
    }
    if (waitingOnValue != null && waitingOnValue is! String) {
      throw DasnProjectionFormatException(
        'TaskProjection.waitingOn must be a string when present',
        waitingOnValue,
      );
    }

    final nextActionsValue = json['nextActions'];
    if (json.containsKey('nextActions') && nextActionsValue == null) {
      throw DasnProjectionFormatException(
        'TaskProjection.nextActions must be an array when present',
        nextActionsValue,
      );
    }
    if (nextActionsValue != null && nextActionsValue is! List) {
      throw DasnProjectionFormatException(
        'TaskProjection.nextActions must be an array when present',
        nextActionsValue,
      );
    }

    final nextActions = <NextAction>[];
    if (nextActionsValue != null) {
      for (var index = 0; index < nextActionsValue.length; index++) {
        final rawAction = nextActionsValue[index];
        if (rawAction is! Map) {
          throw DasnProjectionFormatException(
            'TaskProjection.nextActions[$index] must be an object',
            rawAction,
          );
        }
        try {
          nextActions.add(
            NextAction.fromJson(Map<String, dynamic>.from(rawAction)),
          );
        } on TypeError {
          throw DasnProjectionFormatException(
            'TaskProjection.nextActions[$index] must use string keys',
            rawAction,
          );
        }
      }
    }

    return TaskProjection(
      taskLifecycle: TaskLifecycle.fromWire(taskLifecycle),
      responsibilityAction: ResponsibilityAction.fromWire(responsibilityAction),
      syncStatus: SyncStatus.fromWire(syncStatus),
      waitingOn: waitingOnValue == null
          ? WaitingOn.none
          : WaitingOn.fromWire(waitingOnValue),
      nextActions: List<NextAction>.unmodifiable(nextActions),
    );
  }

  factory TaskProjection.fromMap(Map<String, dynamic> json) =>
      TaskProjection.fromJson(json);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'taskLifecycle': taskLifecycle.wireValue,
      'responsibilityAction': responsibilityAction.wireValue,
      'syncStatus': syncStatus.wireValue,
      if (waitingOn != WaitingOn.none) 'waitingOn': waitingOn.wireValue,
      if (nextActions.isNotEmpty)
        'nextActions': nextActions.map((action) => action.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TaskProjection ||
        other.taskLifecycle != taskLifecycle ||
        other.responsibilityAction != responsibilityAction ||
        other.syncStatus != syncStatus ||
        other.waitingOn != waitingOn ||
        other.nextActions.length != nextActions.length) {
      return false;
    }
    for (var index = 0; index < nextActions.length; index++) {
      if (nextActions[index] != other.nextActions[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        taskLifecycle,
        responsibilityAction,
        syncStatus,
        waitingOn,
        Object.hashAll(nextActions),
      );

  static String _requiredString(Map<String, dynamic> json, String field) {
    if (!json.containsKey(field) || json[field] == null) {
      throw DasnProjectionFormatException(
        'TaskProjection.$field is required',
        json,
      );
    }
    final value = json[field];
    if (value is! String || value.trim().isEmpty) {
      throw DasnProjectionFormatException(
        'TaskProjection.$field must be a non-empty string',
        value,
      );
    }
    return value;
  }
}
