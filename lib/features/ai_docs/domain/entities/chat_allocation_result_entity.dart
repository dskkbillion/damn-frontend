import 'package:equatable/equatable.dart';

/// {@template chat_allocation_result_entity}
/// Represents the result of successfully allocating a chat,
/// typically returned by the /chat/allocate endpoint.
/// {@endtemplate}
class ChatAllocationResultEntity extends Equatable {
  /// A summary or suggested next steps for the allocated chat.
  final String summary;
  /// The ID of the merchant or agent the chat was allocated to.
  final int merchantId;
  /// Optional: Information about a specific item related to the allocation.
  final Map<String, dynamic>? item; // Keeping item as Map for now

  /// {@macro chat_allocation_result_entity}
  const ChatAllocationResultEntity({
    required this.summary,
    required this.merchantId,
    this.item, 
  });

  @override
  List<Object?> get props => [summary, merchantId, item];
} 