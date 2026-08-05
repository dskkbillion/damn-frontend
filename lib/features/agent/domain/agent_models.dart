class AgentAuthorization {
  final String clientName;
  final String? clientType;
  final String? deviceName;
  final String? platform;
  final String? cliVersion;
  final Set<String> requestedScopes;
  final String status;
  final DateTime expiresAt;

  const AgentAuthorization({
    required this.clientName,
    required this.clientType,
    required this.deviceName,
    required this.platform,
    required this.cliVersion,
    required this.requestedScopes,
    required this.status,
    required this.expiresAt,
  });

  factory AgentAuthorization.fromJson(Map<String, dynamic> json) =>
      AgentAuthorization(
        clientName: json['clientName'] as String? ?? 'Unknown Agent',
        clientType: json['clientType'] as String?,
        deviceName: json['deviceName'] as String?,
        platform: json['platform'] as String?,
        cliVersion: json['cliVersion'] as String?,
        requestedScopes: _stringSet(json['requestedScopes']),
        status: json['status'] as String? ?? 'UNKNOWN',
        expiresAt: _date(json['expiresAt']) ?? DateTime.now(),
      );
}

class AgentSession {
  final int id;
  final int clientId;
  final String clientName;
  final String? clientType;
  final String? deviceName;
  final String? platform;
  final String? cliVersion;
  final Set<String> scopes;
  final String status;
  final DateTime? accessExpiresAt;
  final DateTime? refreshExpiresAt;
  final DateTime? lastUsedAt;
  final DateTime? createdAt;

  const AgentSession({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientType,
    required this.deviceName,
    required this.platform,
    required this.cliVersion,
    required this.scopes,
    required this.status,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
    required this.lastUsedAt,
    required this.createdAt,
  });

  factory AgentSession.fromJson(Map<String, dynamic> json) => AgentSession(
        id: (json['id'] as num).toInt(),
        clientId: (json['clientId'] as num).toInt(),
        clientName: json['clientName'] as String? ?? 'Unknown Agent',
        clientType: json['clientType'] as String?,
        deviceName: json['deviceName'] as String?,
        platform: json['platform'] as String?,
        cliVersion: json['cliVersion'] as String?,
        scopes: _stringSet(json['scopes']),
        status: json['status'] as String? ?? 'UNKNOWN',
        accessExpiresAt: _date(json['accessExpiresAt']),
        refreshExpiresAt: _date(json['refreshExpiresAt']),
        lastUsedAt: _date(json['lastUsedAt']),
        createdAt: _date(json['createdAt']),
      );
}

class AgentSessionPage {
  final List<AgentSession> items;
  final bool hasMore;
  final int? nextCursor;
  final int limit;

  const AgentSessionPage({
    required this.items,
    required this.hasMore,
    required this.nextCursor,
    required this.limit,
  });

  factory AgentSessionPage.fromJson(Map<String, dynamic> json) =>
      AgentSessionPage(
        items: ((json['items'] as List?) ?? const [])
            .map((item) =>
                AgentSession.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList(),
        hasMore: json['hasMore'] as bool? ?? false,
        nextCursor: (json['nextCursor'] as num?)?.toInt(),
        limit: (json['limit'] as num?)?.toInt() ?? 20,
      );
}

class AgentAuditEvent {
  final String action;
  final String result;
  final String? metadata;
  final DateTime? createdAt;

  const AgentAuditEvent(
      this.action, this.result, this.metadata, this.createdAt);
  factory AgentAuditEvent.fromJson(Map<String, dynamic> json) =>
      AgentAuditEvent(
        json['action'] as String? ?? 'UNKNOWN',
        json['result'] as String? ?? 'UNKNOWN',
        json['metadata'] as String?,
        _date(json['createdAt']),
      );
}

class AgentSessionDetail {
  final AgentSession session;
  final List<AgentAuditEvent> events;
  const AgentSessionDetail(this.session, this.events);
  factory AgentSessionDetail.fromJson(Map<String, dynamic> json) =>
      AgentSessionDetail(
        AgentSession.fromJson(
            Map<String, dynamic>.from(json['session'] as Map)),
        ((json['recentSecurityEvents'] as List?) ?? const [])
            .map((item) => AgentAuditEvent.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .toList(),
      );
}

class AgentRequestDraft {
  final int id;

  /// Server-owned DS 0.1 task lineage.  A missing value is retained for
  /// older request rows so the review page can remain backwards compatible.
  final String? taskTraceId;
  final int? version;

  /// Server-computed DS 0.1 request specification hash used by canonical App
  /// compare-and-submit.  Older rows may omit it and must fail closed.
  final String? specHash;

  /// Server-owned DS 0.2 provenance for the requester.  The App keeps this
  /// fact read-only and uses it only to choose the ingress adapter: HUMAN
  /// requests may continue through the App order facade, while AGENT requests
  /// stop at a credential-free Buyer Agent handoff.  Both converge again on
  /// the same payment and task projection routes after Commitment exists.
  final String? requesterActorType;

  /// Server-owned, non-secret identity binding shared by the Trusted App and
  /// the external Buyer Agent handoff.  It is intentionally optional for
  /// legacy rows; DS 0.2 Agent-origin requests must fail closed when absent.
  final String? principalRef;
  final int? serviceId;
  final String title;
  final String brief;
  final String status;
  final int? providerMemberId;
  final int? chatId;
  final int? initialMessageId;
  final String? appReviewUrl;
  final DateTime? submittedAt;
  final DateTime? providerRespondedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AgentRequestDraft({
    required this.id,
    this.taskTraceId,
    this.version,
    this.specHash,
    this.requesterActorType,
    this.principalRef,
    required this.serviceId,
    required this.title,
    required this.brief,
    required this.status,
    this.providerMemberId,
    this.chatId,
    this.initialMessageId,
    required this.appReviewUrl,
    this.submittedAt,
    this.providerRespondedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AgentRequestDraft.fromJson(Map<String, dynamic> json) =>
      AgentRequestDraft(
        id: (json['id'] as num).toInt(),
        taskTraceId: _stringOrNull(json['taskTraceId']),
        version: (json['version'] as num?)?.toInt(),
        specHash: _stringOrNull(json['specHash']),
        requesterActorType: _stringOrNull(json['requesterActorType']),
        principalRef: _stringOrNull(json['principalRef']),
        serviceId: (json['serviceId'] as num?)?.toInt(),
        title: json['title'] as String? ?? '',
        brief: json['brief'] as String? ?? '',
        status: json['status'] as String? ?? 'UNKNOWN',
        providerMemberId: (json['providerMemberId'] as num?)?.toInt(),
        chatId: (json['chatId'] as num?)?.toInt(),
        initialMessageId: (json['initialMessageId'] as num?)?.toInt(),
        appReviewUrl: json['appReviewUrl'] as String?,
        submittedAt: _date(json['submittedAt']),
        providerRespondedAt: _date(json['providerRespondedAt']),
        createdAt: _date(json['createdAt']),
        updatedAt: _date(json['updatedAt']),
      );
}

String? _stringOrNull(dynamic value) {
  if (value == null) return null;
  final string = value.toString().trim();
  return string.isEmpty ? null : string;
}

Set<String> _stringSet(dynamic value) =>
    ((value as List?) ?? const []).map((item) => item.toString()).toSet();

DateTime? _date(dynamic value) => value == null
    ? null
    : DateTime.tryParse(value.toString().replaceFirst(' ', 'T'));
