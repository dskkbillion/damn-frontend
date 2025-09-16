import 'package:dskk_flutter_refactor/features/chat/domain/entities/participant.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'participant_dto.freezed.dart';
part 'participant_dto.g.dart';

@freezed
class ParticipantDto with _$ParticipantDto {
  const factory ParticipantDto({
    required int id,
    String? nickName,
    String? trueName,
    String? mobile,
    String? avatar,
    String? type, // 'MEMBER', 'DOCTOR', 'ADMIN'
    int? referId,
  }) = _ParticipantDto;

  const ParticipantDto._();

  factory ParticipantDto.fromJson(Map<String, dynamic> json) =>
      _$ParticipantDtoFromJson(json);

  Participant toEntity() {
    // 聊天列表只显示nickName或mobile，不显示trueName
    String? displayName;

    if (nickName?.isNotEmpty == true) {
      displayName = nickName;
    } else if (mobile?.isNotEmpty == true) {
      // 如果mobile包含*，说明是被mask的，优先显示"用户"而不是mask的手机号
      if (mobile!.contains('*')) {
        displayName = '用户${id.toString().padLeft(4, '0')}';
      } else {
        displayName = mobile;
      }
    } else {
      displayName = '用户${id.toString().padLeft(4, '0')}';
    }

    return Participant(
      id: id,
      nickName: displayName,
      avatar: avatar,
      type: type,
      referId: referId,
    );
  }
  
  factory ParticipantDto.fromEntity(Participant entity) {
    return ParticipantDto(
      id: entity.id,
      nickName: entity.nickName,
      trueName: null,
      mobile: null,
      avatar: entity.avatar,
      type: entity.type,
      referId: entity.referId,
    );
  }
} 