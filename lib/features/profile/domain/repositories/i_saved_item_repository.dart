import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/saved_item.dart';

/// 定义收藏项目相关的数据访问接口（由 Saved 模块提供实现）
abstract class ISavedItemRepository {
  /// 获取收藏项目列表
  ///
  /// [page] 分页页码，从 1 开始
  /// [pageSize] 每页数量
  /// 返回 [SavedItem] 列表或 [Failure]
  Future<Either<Failure, List<SavedItem>>> getSavedItems({
    int page = 1,
    int pageSize = 10,
  });
}
