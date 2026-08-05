import '../domain/dsn_buyer_agent_models.dart';
import '../domain/dsn_order_models.dart';

/// Shared contract for the external Buyer Agent/CLI adapter.
///
/// The Flutter Trusted App intentionally has no Dio implementation of this
/// repository.  Calling `/agent/v1/requests/{id}/commitment` requires an Agent
/// session and a server-side BoundedGrant; an App JWT must not be upgraded or
/// forwarded as that credential.  A CLI/runner adapter may implement this
/// contract, map the canonical error envelope into [DsnOrderApiException],
/// and then let the App read the resulting order from the normal task
/// projection and payment routes.
///
/// The request body is exactly [DsnBuyerAgentCommitmentInput.toJson].  The
/// caller supplies the Agent route's If-Match request version and an
/// idempotency key; neither is a hidden field inside the six-fact input.
abstract interface class DsnBuyerAgentCommitmentRepository {
  Future<DsnOrder> createCommitment(
    int requestId, {
    required DsnBuyerAgentCommitmentInput input,
    required int ifMatchVersion,
    required String idempotencyKey,
  });
}
