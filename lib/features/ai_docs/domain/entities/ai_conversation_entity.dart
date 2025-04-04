import 'package:equatable/equatable.dart';

/// {@template ai_conversation_entity}
/// Represents a single AI chat conversation in the domain layer.
///
/// This is a pure data class, free from data layer concerns like JSON parsing.
/// {@endtemplate}
class AiConversationEntity extends Equatable {
  final int id;
  final String? title; // Title might be optional
  final DateTime? createdAt; // Made nullable to handle parsing issues
  final DateTime? updatedAt; // Made nullable to handle parsing issues
  // userId removed as it's not directly available in the corresponding Model from the API list view

  /// {@macro ai_conversation_entity}
  const AiConversationEntity({
    required this.id,
    this.title,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, createdAt, updatedAt];

  // Entities usually don't have fromJson/toJson or toModel methods.
  // Conversion happens in the Model or Repository.
} 