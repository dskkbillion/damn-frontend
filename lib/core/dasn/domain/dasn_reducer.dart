import 'task_projection.dart';

/// Computes exactly one safe primary action for a projection.
///
/// Priority is intentionally fixed by the interaction specification:
/// unknown command result > stale projection > pending responsibility >
/// counterparty/system waiting > terminal record > domain next step.
class DasnNextActionReducer {
  const DasnNextActionReducer._();

  static NextAction reduce(TaskProjection projection) {
    if (projection.syncStatus == SyncStatus.unknown) {
      return NextAction.recoverOperation();
    }
    if (projection.syncStatus == SyncStatus.stale) {
      return NextAction.recoverTask();
    }
    if (projection.syncStatus == SyncStatus.recovering) {
      return NextAction.recoveryInProgress();
    }
    if (projection.taskLifecycle == TaskLifecycle.unknown ||
        projection.responsibilityAction == ResponsibilityAction.unknown ||
        projection.waitingOn == WaitingOn.unknown) {
      return NextAction.unknown();
    }
    if (projection.hasPendingResponsibilityAction) {
      return NextAction.reviewResponsibility();
    }
    if (projection.waitingOn == WaitingOn.counterparty) {
      return NextAction.viewProgress();
    }
    if (projection.waitingOn == WaitingOn.system) {
      return NextAction.viewSystemStatus();
    }
    if (projection.taskLifecycle == TaskLifecycle.completed ||
        projection.taskLifecycle == TaskLifecycle.cancelled) {
      return NextAction.viewRecord();
    }

    if (projection.nextActions.isNotEmpty) {
      final domainAction = projection.nextActions.first;
      return domainAction.isUnknown ? NextAction.unknown() : domainAction;
    }
    return NextAction.unknown();
  }

  NextAction call(TaskProjection projection) => reduce(projection);
}

/// Short top-level form for callers that do not need to instantiate a
/// reducer.
NextAction reduceDasnNextAction(TaskProjection projection) =>
    DasnNextActionReducer.reduce(projection);
