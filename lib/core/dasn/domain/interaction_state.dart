/// The three orthogonal interaction axes defined by DASN interaction v1.2.
///
/// These values are deliberately kept independent from product/order/payment
/// states.  An unrecognised wire value is represented by [unknown] so that a
/// client can fail closed instead of guessing a new business transition.
enum TaskLifecycle {
  draft('DRAFT'),
  aligning('ALIGNING'),
  ready('READY'),
  running('RUNNING'),
  completed('COMPLETED'),
  cancelled('CANCELLED'),
  unknown('UNKNOWN');

  const TaskLifecycle(this.wireValue);

  final String wireValue;

  static TaskLifecycle fromWire(String value) {
    final normalized = value.trim().toUpperCase();
    for (final state in TaskLifecycle.values) {
      if (state.wireValue == normalized && state != TaskLifecycle.unknown) {
        return state;
      }
    }
    return TaskLifecycle.unknown;
  }

  static TaskLifecycle fromJsonString(String value) => fromWire(value);

  String toJsonString() => wireValue;
}

/// The persisted logical status of a one-shot ResponsibilityAction.
///
/// `NONE` is accepted for projections that have no pending action.  It is a
/// projection-level convenience and is not a server-side action status.
enum ResponsibilityAction {
  none('NONE'),
  pending('PENDING'),
  viewing('VIEWING'),
  committing('COMMITTING'),
  approved('APPROVED'),
  declined('DECLINED'),
  unknown('UNKNOWN'),
  expired('EXPIRED'),
  revoked('REVOKED');

  const ResponsibilityAction(this.wireValue);

  final String wireValue;

  static ResponsibilityAction fromWire(String value) {
    final normalized = value.trim().toUpperCase();
    for (final action in ResponsibilityAction.values) {
      if (action.wireValue == normalized &&
          action != ResponsibilityAction.unknown) {
        return action;
      }
    }
    return ResponsibilityAction.unknown;
  }

  static ResponsibilityAction fromJsonString(String value) => fromWire(value);

  String toJsonString() => wireValue;
}

enum SyncStatus {
  synced('SYNCED'),
  stale('STALE'),
  unknown('UNKNOWN'),
  recovering('RECOVERING');

  const SyncStatus(this.wireValue);

  final String wireValue;

  static SyncStatus fromWire(String value) {
    final normalized = value.trim().toUpperCase();
    for (final status in SyncStatus.values) {
      if (status.wireValue == normalized && status != SyncStatus.unknown) {
        return status;
      }
    }
    return SyncStatus.unknown;
  }

  static SyncStatus fromJsonString(String value) => fromWire(value);

  String toJsonString() => wireValue;
}

/// Who the task is waiting on.  This deliberately does not become part of
/// [TaskLifecycle]; it is a projection hint used only to choose the safe next
/// action.
enum WaitingOn {
  none('NONE'),
  principal('PRINCIPAL'),
  counterparty('COUNTERPARTY'),
  system('SYSTEM'),
  unknown('UNKNOWN');

  const WaitingOn(this.wireValue);

  final String wireValue;

  static WaitingOn fromWire(String value) {
    final normalized = value.trim().toUpperCase();
    for (final waitingOn in WaitingOn.values) {
      if (waitingOn.wireValue == normalized && waitingOn != WaitingOn.unknown) {
        return waitingOn;
      }
    }
    return WaitingOn.unknown;
  }

  static WaitingOn fromJsonString(String value) => fromWire(value);

  String toJsonString() => wireValue;
}
