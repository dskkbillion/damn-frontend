import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/user_info.dart';

part 'user_info_model.freezed.dart';
part 'user_info_model.g.dart';

@freezed
class UserInfoModel with _$UserInfoModel {
  const UserInfoModel._(); // Private constructor for entity conversion method

  const factory UserInfoModel({
    // Match fields from UserInfo entity and potential API response structure
    required int id,
    String? mobile,
    @JsonKey(name: 'nickname') // Example: if API uses 'nickname' instead of 'nickName'
    String? nickName,
    String? avatar,
    // Add other fields based on the actual /api/member/info response
  }) = _UserInfoModel;

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);

  // Convert Data Transfer Object (Model) to Domain Entity
  UserInfo toEntity() {
    return UserInfo(
      id: id,
      mobile: mobile,
      nickName: nickName,
      avatar: avatar,
    );
  }
}
