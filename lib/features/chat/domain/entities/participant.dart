import 'package:equatable/equatable.dart';

/// Represents a participant in a chat room.
class Participant extends Equatable {
  final int id;
  final String? nickName;
  final String? avatar;
  final String? type; // e.g., 'MEMBER', 'DOCTOR', 'ADMIN'
  final int? referId;

  const Participant({
    required this.id,
    this.nickName,
    this.avatar,
    this.type,
    this.referId,
  });

  @override
  List<Object?> get props => [id, nickName, avatar, type, referId];

  Participant copyWith({
    int? id,
    String? nickName,
    String? avatar,
    String? type,
    int? referId,
  }) {
    return Participant(
      id: id ?? this.id,
      nickName: nickName ?? this.nickName,
      avatar: avatar ?? this.avatar,
      type: type ?? this.type,
      referId: referId ?? this.referId,
    );
  }
} 