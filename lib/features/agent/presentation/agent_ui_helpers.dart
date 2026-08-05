import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import '../data/agent_repository.dart';

String agentScopeLabel(BuildContext context, String scope) {
  final l10n = AppLocalizations.of(context);
  switch (scope) {
    case 'services:read':
      return l10n.agentScopeServicesRead;
    case 'requests:read':
      return l10n.agentScopeRequestsRead;
    case 'requests:create':
      return l10n.agentScopeRequestsCreate;
    default:
      return scope;
  }
}

String agentStatusLabel(BuildContext context, String status) {
  final l10n = AppLocalizations.of(context);
  switch (status) {
    case 'ACTIVE':
      return l10n.agentStatusActive;
    case 'REVOKED':
      return l10n.agentStatusRevoked;
    case 'EXPIRED':
      return l10n.agentStatusExpired;
    case 'AWAITING_APP_REVIEW':
      return l10n.agentStatusAwaitingReview;
    case 'SUBMITTED':
      return l10n.agentStatusSubmitted;
    case 'PROVIDER_RESPONDED':
      return l10n.agentStatusProviderResponded;
    case 'ABANDONED':
      return l10n.agentStatusAbandoned;
    default:
      return status;
  }
}

String agentDate(DateTime? value) =>
    value == null ? '—' : DateFormat.yMd().add_Hm().format(value.toLocal());

String normalizeAgentCode(String value) {
  final compact = value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  if (compact.length <= 4) return compact;
  final end = compact.length > 8 ? 8 : compact.length;
  return '${compact.substring(0, 4)}-${compact.substring(4, end)}';
}

// TestFlight staging archives are release-mode Flutter builds, so kReleaseMode
// alone cannot distinguish them from the public production app. The release
// xcconfig passes ENV_FILE=.env.staging for those archives. Only this known
// staging marker (or a non-release build) enables diagnostics; arbitrary
// server messages are never rendered here.
const String _agentEnvironmentFile =
    String.fromEnvironment('ENV_FILE', defaultValue: '.env');

bool get _showAgentDiagnostics =>
    !kReleaseMode || _agentEnvironmentFile.endsWith('.staging');

String? _canonicalAgentErrorCode(Object error) {
  if (error is! AgentApiException) return null;
  final code = error.code?.trim();
  if (code == null || code.isEmpty) return null;

  // Keep diagnostics machine-readable without allowing arbitrary server text
  // (which could contain identifiers, URLs, or implementation details) into
  // the UI.
  if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_.:-]{0,127}$').hasMatch(code)) {
    return null;
  }
  return code;
}

String agentErrorMessage(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context);
  final code = error is AgentApiException ? error.code : null;
  final String message;
  switch (code) {
    case 'invalid_user_code':
      message = l10n.agentErrorInvalidCode;
      break;
    case 'expired_token':
      message = l10n.agentErrorExpired;
      break;
    case 'invalid_grant':
      message = l10n.agentErrorAlreadyUsed;
      break;
    case 'access_denied':
      message = l10n.agentErrorDenied;
      break;
    case 'rate_limited':
      message = l10n.agentErrorRateLimited;
      break;
    case 'not_found':
      message = l10n.agentErrorNotFound;
      break;
    default:
      message = l10n.agentErrorGeneric;
      break;
  }

  final diagnosticCode =
      _showAgentDiagnostics ? _canonicalAgentErrorCode(error) : null;
  if (diagnosticCode == null) return message;
  return '$message [$diagnosticCode]';
}

String agentAuthorizationStatusMessage(BuildContext context, String status) {
  final l10n = AppLocalizations.of(context);
  switch (status) {
    case 'APPROVED':
      return l10n.agentAuthorizationAlreadyApproved;
    case 'DENIED':
      return l10n.agentAuthorizationAlreadyDenied;
    case 'CONSUMED':
      return l10n.agentAuthorizationAlreadyUsed;
    default:
      return l10n.agentAuthorizationUnavailable;
  }
}

String agentAuditActionLabel(BuildContext context, String action) {
  final l10n = AppLocalizations.of(context);
  switch (action) {
    case 'DEVICE_TOKEN':
      return l10n.agentAuditConnected;
    case 'DEVICE_AUTHORIZE':
      return l10n.agentAuditAuthorizationRequested;
    case 'DEVICE_APPROVE':
      return l10n.agentAuditAuthorizationApproved;
    case 'DEVICE_DENY':
      return l10n.agentAuditAuthorizationDenied;
    case 'TOKEN_REFRESH':
      return l10n.agentAuditRefreshed;
    case 'REFRESH_REPLAY':
      return l10n.agentAuditReplayBlocked;
    case 'SESSION_SCOPE_REDUCE':
      return l10n.agentAuditPermissionsReduced;
    case 'SESSION_REVOKE':
      return l10n.agentAuditRevoked;
    case 'SESSION_REVOKE_ALL':
      return l10n.agentAuditAllRevoked;
    case 'REQUEST_DRAFT_CREATE':
      return l10n.agentAuditRequestCreated;
    case 'REQUEST_SUBMIT_TO_PROVIDER':
      return l10n.agentAuditRequestApproved;
    case 'REQUEST_PROVIDER_RESPONDED':
      return l10n.agentStatusProviderResponded;
    case 'REQUEST_APP_ABANDON':
      return l10n.agentAuditRequestAbandoned;
    default:
      return l10n.agentAuditSecurityEvent;
  }
}

String agentAuditResultLabel(BuildContext context, String result) {
  final l10n = AppLocalizations.of(context);
  switch (result) {
    case 'SUCCESS':
      return l10n.agentAuditSuccess;
    case 'REVOKED':
      return l10n.agentStatusRevoked;
    default:
      return l10n.agentAuditRecorded;
  }
}
