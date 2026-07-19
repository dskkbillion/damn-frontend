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
  final int? serviceId;
  final String title;
  final String brief;
  final String status;
  final String? appReviewUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AgentRequestDraft({
    required this.id,
    required this.serviceId,
    required this.title,
    required this.brief,
    required this.status,
    required this.appReviewUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AgentRequestDraft.fromJson(Map<String, dynamic> json) =>
      AgentRequestDraft(
        id: (json['id'] as num).toInt(),
        serviceId: (json['serviceId'] as num?)?.toInt(),
        title: json['title'] as String? ?? '',
        brief: json['brief'] as String? ?? '',
        status: json['status'] as String? ?? 'UNKNOWN',
        appReviewUrl: json['appReviewUrl'] as String?,
        createdAt: _date(json['createdAt']),
        updatedAt: _date(json['updatedAt']),
      );
}

Set<String> _stringSet(dynamic value) =>
    ((value as List?) ?? const []).map((item) => item.toString()).toSet();

DateTime? _date(dynamic value) => value == null
    ? null
    : DateTime.tryParse(value.toString().replaceFirst(' ', 'T'));
