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
    case 'APPROVED':
      return l10n.agentStatusApproved;
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

String agentErrorMessage(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context);
  final code = error is AgentApiException ? error.code : null;
  switch (code) {
    case 'invalid_user_code':
      return l10n.agentErrorInvalidCode;
    case 'expired_token':
      return l10n.agentErrorExpired;
    case 'invalid_grant':
      return l10n.agentErrorAlreadyUsed;
    case 'access_denied':
      return l10n.agentErrorDenied;
    case 'rate_limited':
      return l10n.agentErrorRateLimited;
    case 'not_found':
      return l10n.agentErrorNotFound;
    default:
      return l10n.agentErrorGeneric;
  }
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
    case 'REQUEST_APP_APPROVE':
      return l10n.agentAuditRequestApproved;
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
