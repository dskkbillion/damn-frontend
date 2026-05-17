// IdResolver — 跨端 ID 语义封装(#358 C 方案的前端落地)。
// 详细背景见 docs/dev/id_schema_cn.md
//
// 设计目标:让业务代码不再直接 read flutter_secure_storage 的 user_id /
// common_user_id,而是按"我需要哪种语义"来调用,集中收口避免再次按变量名猜
// (历史教训:#172、#355、#346)。
//
// 关联 issue:#358 (ID schema 梳理 epic)

import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';

/// 跨端 ID 语义解析器。
///
/// **使用规则**
/// - 调 Java 后端期望 `member.id` 的 endpoint(如 chat addChat):用
///   [memberIdForBackend]
/// - 调 model-backend allocate / 推荐 / WebSocket 等 `xun_common_user.id`
///   场景:用 [commonUserId]
/// - 不确定该用哪个 → 先查 `docs/dev/id_schema_cn.md` §2 跨端契约清单。
abstract class IdResolver {
  /// 返回 `member.id`(C 端买家在 `member` 表的纯主键)。
  ///
  /// 适用场景: Java 后端 `/api/chat/addChat` 的 `doctorId` 入参、其他**期望
  /// 业务表 PK** 的旧 endpoint。
  Future<int?> memberIdForBackend();

  /// 返回 `xun_common_user.id`(跨身份的统一身份代理 ID)。
  ///
  /// 适用场景: chat 表内部存的 doctor_id/member_id、model-backend
  /// `/model/chat/allocate` 的 user_id / merchant_id、推荐 API 输出的
  /// tenantId、WebSocket 消息字段、Milvus user_collection.id。
  Future<int?> commonUserId();
}

class IdResolverImpl implements IdResolver {
  final ISecureStorageRepository _storage;

  IdResolverImpl(this._storage);

  @override
  Future<int?> memberIdForBackend() => _storage.getUserId();

  @override
  Future<int?> commonUserId() => _storage.getCommonUserId();
}
