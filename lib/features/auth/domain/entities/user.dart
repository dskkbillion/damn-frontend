import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String commonUserId; // Unique ID across the system, used for WebSocket topic
  final String? nickName;
  final String? avatar;
  final String? type; // e.g., 'MEMBER', 'DOCTOR', 'ADMIN'

  const User({
    required this.id,
    required this.commonUserId,
    this.nickName,
    this.avatar,
    this.type,
  });

  @override
  List<Object?> get props => [id, commonUserId, nickName, avatar, type];
} 