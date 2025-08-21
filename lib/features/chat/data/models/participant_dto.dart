import 'package:dskk_flutter_refactor/features/chat/domain/entities/participant.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'participant_dto.freezed.dart';
part 'participant_dto.g.dart';

@freezed
class ParticipantDto with _$ParticipantDto {
  const factory ParticipantDto({
    required int id,
    String? nickName,
    String? avatar,
    String? type, // 'MEMBER', 'DOCTOR', 'ADMIN'
    int? referId,
    // Add other fields from API if needed (e.g., trueName, mobile)
  }) = _ParticipantDto;

  const ParticipantDto._();

  factory ParticipantDto.fromJson(Map<String, dynamic> json) =>
      _$ParticipantDtoFromJson(json);

  Participant toEntity() {
    return Participant(
      id: id,
      nickName: nickName,
      avatar: avatar,
      type: type,
      referId: referId,
    );
  }
  
  factory ParticipantDto.fromEntity(Participant entity) {
    return ParticipantDto(
      id: entity.id,
      nickName: entity.nickName,
      avatar: entity.avatar,
      type: entity.type,
      referId: entity.referId,
    );
  }
} 