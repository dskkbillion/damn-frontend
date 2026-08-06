/// Server-owned service capability facts used by the HUMAN App ingress.
///
/// A request must bind to the exact revision returned by the canonical App
/// capability endpoint.  The client deliberately does not manufacture a
/// revision from product details or keep a placeholder hash.
class DsnServiceCapability {
  const DsnServiceCapability({
    required this.serviceId,
    required this.capabilityId,
    required this.revision,
    required this.title,
    required this.description,
    required this.amountMinor,
    required this.currency,
    required this.deliveryHours,
    required this.maxRevisions,
    required this.outputTypes,
  });

  final int serviceId;
  final String capabilityId;
  final String revision;
  final String title;
  final String description;
  final int amountMinor;
  final String currency;
  final int deliveryHours;
  final int maxRevisions;
  final List<String> outputTypes;
}

class DsnServiceCapabilityFormatException implements Exception {
  const DsnServiceCapabilityFormatException(this.message,
      {this.code = 'INVALID_CAPABILITY_RESPONSE'});

  final String message;
  final String code;

  @override
  String toString() => message;
}
