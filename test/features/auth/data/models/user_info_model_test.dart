import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/features/auth/data/models/user_info_model.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/user_info.dart';

// 实际的 /api/member/info 响应 data 部分
const String fixtureUserInfoJson = '''
{
    "createTime": "2024-08-21 16:40:53",
    "updateTime": null,
    "sort": 0,
    "id": 10302,
    "signature": null,
    "birthday": null,
    "vipTime": null,
    "mobile": "17895868541",
    "nickName": "178****1",
    "trueName": null,
    "avatar": null,
    "gender": "NONE",
    "status": "ENABLE",
    "type": "DEFAULT",
    "province": null,
    "remarks": null,
    "weminiOpenid": null,
    "weappOpenid": null,
    "weUnionid": null,
    "realNameFlag": false,
    "attestationName": null,
    "productNum": null,
    "orderNum": null,
    "buyOrderNum": null,
    "ip": null,
    "loginTime": null,
    "recoverFlag": false,
    "commonUserId": 10297,
    "onlineFlag": true,
    "lastLoginTime": null,
    "payPriceTotal": null,
    "inviter": null,
    "isApplyDel": 0,
    "age": null,
    "xingzuo": null
}
''';

void main() {
  const tUserInfoModel = UserInfoModel(
    id: 10302,
    mobile: "17895868541",
    nickName: "178****1",
    avatar: null,
    commonUserId: 10297,
  );

  test(
    'should be a subclass of UserInfo entity',
    () async {
      // assert
      expect(tUserInfoModel, isA<UserInfo>());
    },
  );

  group('fromJson', () {
    test(
      'should return a valid model when the JSON is correct',
      () async {
        // arrange
        final Map<String, dynamic> jsonMap = json.decode(fixtureUserInfoJson) as Map<String, dynamic>;
        // act
        final result = UserInfoModel.fromJson(jsonMap);
        // assert
        expect(result.id, 10302);
        expect(result.mobile, "17895868541");
        expect(result.nickName, "178****1");
        expect(result.avatar, isNull);
        expect(result.commonUserId, 10297);
      },
    );

    test(
      'should throw a TypeError when the JSON is missing id',
      () async {
        // arrange
        final Map<String, dynamic> jsonMap = json.decode(fixtureUserInfoJson) as Map<String, dynamic>;
        jsonMap.remove('id'); // 移除 id
        // act & assert
        // freezed+json_serializable throws TypeError when required field is missing
        expect(() => UserInfoModel.fromJson(jsonMap), throwsA(isA<TypeError>()));
      },
    );

     test(
      'should throw a TypeError when the JSON id is not an integer',
      () async {
        // arrange
        final Map<String, dynamic> jsonMap = json.decode(fixtureUserInfoJson) as Map<String, dynamic>;
        jsonMap['id'] = 'not_an_int'; // id 类型错误
        // act & assert
        // freezed+json_serializable throws TypeError when type cast fails
        expect(() => UserInfoModel.fromJson(jsonMap), throwsA(isA<TypeError>()));
      },
    );

    // 可以添加更多测试用例来覆盖可选字段为 null 或非 null 的情况
  });

  // toJson 方法的测试（如果 UserInfoModel 需要 toJson）
  // group('toJson', () {
  //   test(
  //     'should return a JSON map containing the proper data',
  //     () async {
  //       // act
  //       final result = tUserInfoModel.toJson();
  //       // assert
  //       final expectedMap = {
  //         "id": 10302,
  //         "mobile": "17895868541",
  //         "nickName": "178****1",
  //         "avatar": null,
  //       };
  //       expect(result, expectedMap);
  //     },
  //   );
  // });
}
