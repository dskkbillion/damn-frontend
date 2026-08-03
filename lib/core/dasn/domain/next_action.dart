import 'dasn_format_exception.dart';

export 'dasn_format_exception.dart';

/// The action chosen by [DasnNextActionReducer].
///
/// The wire contract allows domain-specific action strings.  The reducer only
/// recognises the small set of recovery/interaction actions it can safely
/// route itself; unrecognised strings become [unknown] and must not be
/// auto-executed by a client.
enum NextActionKind {
  recoverOperation('RECOVER_OPERATION'),
  recoverTask('RECOVER_TASK'),
  reviewResponsibility('REVIEW_RESPONSIBILITY'),
  recoveryInProgress('RECOVERY_IN_PROGRESS'),
  viewProgress('VIEW_PROGRESS'),
  viewSystemStatus('VIEW_SYSTEM_STATUS'),
  viewRecord('VIEW_RECORD'),
  domain('DOMAIN_NEXT_STEP'),
  unknown('UNKNOWN');

  const NextActionKind(this.defaultWireValue);

  final String defaultWireValue;
}

/// A machine next action from a projection or the local safety reducer.
class NextAction {
  NextAction({required String type, this.appUrl})
      : type = _requireType(type),
        kind = _kindFor(type);

  NextAction._internal({
    required this.type,
    required this.kind,
    this.appUrl,
  });

  final String type;
  final Uri? appUrl;
  final NextActionKind kind;

  bool get isUnknown => kind == NextActionKind.unknown;

  /// Only known, explicitly safe actions can be routed by the local reducer.
  /// Domain actions are still displayable, but their execution semantics must
  /// come from the current domain adapter rather than this generic layer.
  bool get isSafeForAutomaticExecution =>
      kind == NextActionKind.recoverOperation ||
      kind == NextActionKind.recoverTask ||
      kind == NextActionKind.recoveryInProgress;

  factory NextAction.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('type') || json['type'] == null) {
      throw DasnProjectionFormatException(
        'NextAction.type is required',
        json,
      );
    }
    final rawType = json['type'];
    if (rawType is! String || rawType.trim().isEmpty) {
      throw DasnProjectionFormatException(
        'NextAction.type must be a non-empty string',
        rawType,
      );
    }

    Uri? appUrl;
    if (json.containsKey('appUrl')) {
      final rawUrl = json['appUrl'];
      if (rawUrl == null || rawUrl is! String || rawUrl.trim().isEmpty) {
        throw DasnProjectionFormatException(
          'NextAction.appUrl must be a URI string when present',
          rawUrl,
        );
      }
      appUrl = Uri.tryParse(rawUrl);
      if (appUrl == null || !appUrl.hasScheme) {
        throw DasnProjectionFormatException(
          'NextAction.appUrl must be an absolute URI',
          rawUrl,
        );
      }
    }

    return NextAction(type: rawType, appUrl: appUrl);
  }

  factory NextAction.fromMap(Map<String, dynamic> json) =>
      NextAction.fromJson(json);

  String get actionType => type;

  NextActionKind get nextActionKind => kind;

  factory NextAction.recoverOperation({Uri? appUrl}) => NextAction._internal(
        type: NextActionKind.recoverOperation.defaultWireValue,
        kind: NextActionKind.recoverOperation,
        appUrl: appUrl,
      );

  factory NextAction.recoverTask({Uri? appUrl}) => NextAction._internal(
        type: NextActionKind.recoverTask.defaultWireValue,
        kind: NextActionKind.recoverTask,
        appUrl: appUrl,
      );

  factory NextAction.reviewResponsibility({Uri? appUrl}) =>
      NextAction._internal(
        type: NextActionKind.reviewResponsibility.defaultWireValue,
        kind: NextActionKind.reviewResponsibility,
        appUrl: appUrl,
      );

  factory NextAction.recoveryInProgress({Uri? appUrl}) => NextAction._internal(
        type: NextActionKind.recoveryInProgress.defaultWireValue,
        kind: NextActionKind.recoveryInProgress,
        appUrl: appUrl,
      );

  factory NextAction.viewProgress({Uri? appUrl}) => NextAction._internal(
        type: NextActionKind.viewProgress.defaultWireValue,
        kind: NextActionKind.viewProgress,
        appUrl: appUrl,
      );

  factory NextAction.viewSystemStatus({Uri? appUrl}) => NextAction._internal(
        type: NextActionKind.viewSystemStatus.defaultWireValue,
        kind: NextActionKind.viewSystemStatus,
        appUrl: appUrl,
      );

  factory NextAction.viewRecord({Uri? appUrl}) => NextAction._internal(
        type: NextActionKind.viewRecord.defaultWireValue,
        kind: NextActionKind.viewRecord,
        appUrl: appUrl,
      );

  factory NextAction.unknown({Uri? appUrl}) => NextAction._internal(
        type: NextActionKind.unknown.defaultWireValue,
        kind: NextActionKind.unknown,
        appUrl: appUrl,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        if (appUrl != null) 'appUrl': appUrl.toString(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NextAction && other.type == type && other.appUrl == appUrl;

  @override
  int get hashCode => Object.hash(type, appUrl);

  static String _requireType(String value) {
    if (value.trim().isEmpty) {
      throw DasnProjectionFormatException(
        'NextAction.type must be a non-empty string',
        value,
      );
    }
    return value;
  }

  static NextActionKind _kindFor(String value) {
    final normalized = value.trim().toUpperCase();
    switch (normalized) {
      case 'RECOVER_OPERATION':
      case 'QUERY_ORIGINAL_OPERATION':
      case 'QUERY_FIRST':
        return NextActionKind.recoverOperation;
      case 'RECOVER_TASK':
        return NextActionKind.recoverTask;
      case 'REVIEW_RESPONSIBILITY':
      case 'HUMAN_CONFIRMATION':
      case 'MANUAL_REVIEW':
      case 'REAUTHORIZE':
        return NextActionKind.reviewResponsibility;
      case 'RECOVERY_IN_PROGRESS':
        return NextActionKind.recoveryInProgress;
      case 'VIEW_PROGRESS':
        return NextActionKind.viewProgress;
      case 'VIEW_SYSTEM_STATUS':
        return NextActionKind.viewSystemStatus;
      case 'VIEW_RECORD':
        return NextActionKind.viewRecord;
      case 'NEXT_STEP':
      case 'DOMAIN_NEXT_STEP':
      case 'REFRESH_AND_CONFIRM':
        return NextActionKind.domain;
      case 'UNKNOWN':
        return NextActionKind.unknown;
      default:
        return NextActionKind.unknown;
    }
  }
}
