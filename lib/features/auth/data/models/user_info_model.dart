import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/user_info.dart';

part 'user_info_model.freezed.dart';
part 'user_info_model.g.dart';

@freezed
class UserInfoModel with _$UserInfoModel implements UserInfo {
  @Implements<UserInfo>() // Let freezed handle Equatable via the UserInfo entity
  const factory UserInfoModel({
    required int id,
    String? mobile,
    String? email,
    String? nickName,
    String? avatar,
    int? commonUserId,
  }) = _UserInfoModel;

  const UserInfoModel._(); // Re-add the private constructor required by freezed for custom getters

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);

  // Explicitly add the overrides again
  @override
  List<Object?> get props => [id, mobile, email, nickName, avatar, commonUserId];

  @override
  bool? get stringify => true;
}
