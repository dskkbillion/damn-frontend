import 'package:get_it/get_it.dart';

import '../domain/dsn_buyer_agent_models.dart';

/// In-process handoff boundary between the Trusted App and an external Buyer
/// Agent integration.
///
/// The broker stores only [DsnBuyerAgentHandoff] facts. It never receives an
/// Agent token, session, Grant, or Member JWT and it never calls the Agent
/// commitment endpoint. A host bridge can read [consumeSafeJson] and pass the
/// returned facts to its external Agent client; the App remains responsible
/// for restoring the resulting Commitment through its task projection.
///
/// A handoff is consumable once. Re-publishing the same handoff is an
/// idempotent no-op (including after consumption), while a different handoff
/// cannot overwrite one that is still waiting for the external consumer.
class DsnBuyerAgentHandoffBroker implements DsnBuyerAgentHandoffSink {
  DsnBuyerAgentHandoff? _pending;
  String? _consumedKey;

  /// Whether an unconsumed handoff is waiting for the external bridge.
  bool get hasPending => _pending != null;

  /// The pending facts for an in-process bridge, without consuming them.
  ///
  /// Callers must not mutate or serialize this as an authenticated request.
  DsnBuyerAgentHandoff? get pending => _pending;

  @override
  void onReady(DsnBuyerAgentHandoff handoff) {
    final key = _handoffKey(handoff);
    final pending = _pending;
    if (pending != null) {
      if (_handoffKey(pending) == key) return;
      throw StateError(
        'A different Buyer Agent handoff is already waiting for consumption',
      );
    }
    // The App page can be rebuilt after a callback has already been consumed.
    // Do not make a one-time confirmation reference reusable by publishing it
    // again from that rebuild.
    if (_consumedKey == key) return;
    _pending = handoff;
  }

  /// Consumes the pending handoff exactly once.
  DsnBuyerAgentHandoff? consume() {
    final handoff = _pending;
    if (handoff == null) return null;
    _pending = null;
    _consumedKey = _handoffKey(handoff);
    return handoff;
  }

  /// Safe, credential-free form for a host bridge to pass to an external
  /// Buyer Agent. Calling this method consumes the handoff.
  Map<String, dynamic>? consumeSafeJson() => consume()?.toSafeJson();

  String _handoffKey(DsnBuyerAgentHandoff handoff) {
    final commitment = handoff.commitment;
    return [
      handoff.requestId,
      handoff.taskTraceId,
      commitment.previewId,
      commitment.providerAcceptanceId,
      commitment.offerVersion,
      commitment.confirmationRef,
    ].join(':');
  }
}

/// Registers the broker and exposes the same instance through the existing
/// [DsnBuyerAgentHandoffSink] abstraction used by the route layer.
///
/// A host may register its own sink before this helper runs; in that case the
/// existing sink is preserved. The default application path uses the broker
/// and therefore has a real, auditable handoff destination without coupling
/// the App to an Agent HTTP client.
void registerDsnBuyerAgentHandoffBroker(GetIt locator) {
  final broker = locator.isRegistered<DsnBuyerAgentHandoffBroker>()
      ? locator<DsnBuyerAgentHandoffBroker>()
      : DsnBuyerAgentHandoffBroker();
  if (!locator.isRegistered<DsnBuyerAgentHandoffBroker>()) {
    locator.registerSingleton<DsnBuyerAgentHandoffBroker>(broker);
  }
  if (!locator.isRegistered<DsnBuyerAgentHandoffSink>()) {
    locator.registerSingleton<DsnBuyerAgentHandoffSink>(broker);
  }
}
