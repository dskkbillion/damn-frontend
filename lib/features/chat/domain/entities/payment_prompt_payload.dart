import 'dart:convert';

import 'package:equatable/equatable.dart';

const String kPaymentPromptType = 'payment_prompt';

class PaymentPromptPayload extends Equatable {
  final String type;
  final String? source;
  final String content;
  final String? productId;
  final int? sellerId;
  final int roundCount;
  final List<PaymentPromptVariant> variants;

  const PaymentPromptPayload({
    required this.type,
    this.source,
    this.content = '',
    this.productId,
    this.sellerId,
    this.roundCount = 0,
    this.variants = const [],
  });

  factory PaymentPromptPayload.fromJson(Map<String, dynamic> json) {
    final rawVariants = json['variants'];
    final variants = rawVariants is List
        ? rawVariants
            .whereType<Map<String, dynamic>>()
            .map(PaymentPromptVariant.fromJson)
            .toList(growable: false)
        : const <PaymentPromptVariant>[];

    return PaymentPromptPayload(
      type: json['type'] as String,
      source: json['source'] as String?,
      content: (json['content'] as String?) ?? '',
      productId: json['productId']?.toString(),
      sellerId: (json['sellerId'] as num?)?.toInt(),
      roundCount: (json['roundCount'] as num?)?.toInt() ?? 0,
      variants: variants,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        if (source != null) 'source': source,
        'content': content,
        if (productId != null) 'productId': productId,
        if (sellerId != null) 'sellerId': sellerId,
        'roundCount': roundCount,
        'variants': variants.map((v) => v.toJson()).toList(),
      };

  /// Returns a [PaymentPromptPayload] when [context] is a JSON-encoded
  /// payment-prompt envelope, or `null` otherwise. Safe to call on any
  /// chat message context — short-circuits before [jsonDecode] for the
  /// common case of plain-text messages.
  static PaymentPromptPayload? tryParse(String? context) {
    if (context == null || context.isEmpty) return null;
    if (!context.startsWith('{')) return null;
    if (!context.contains('"$kPaymentPromptType"')) return null;

    final dynamic decoded;
    try {
      decoded = jsonDecode(context);
    } catch (_) {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;
    if (decoded['type'] != kPaymentPromptType) return null;

    return PaymentPromptPayload.fromJson(decoded);
  }

  @override
  List<Object?> get props =>
      [type, source, content, productId, sellerId, roundCount, variants];
}

class PaymentPromptVariant extends Equatable {
  final num id;
  final num price;
  final String? name;

  const PaymentPromptVariant({
    required this.id,
    required this.price,
    this.name,
  });

  factory PaymentPromptVariant.fromJson(Map<String, dynamic> json) =>
      PaymentPromptVariant(
        id: json['id'] as num,
        price: json['price'] as num,
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'price': price,
        if (name != null) 'name': name,
      };

  @override
  List<Object?> get props => [id, price, name];
}
