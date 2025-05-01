import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/home_page_data.dart';
import '../repositories/home_repository.dart';

/// 获取首屏所需的聚合数据（Banner、分类、第一页信息流）
class GetHomePageDataUseCase implements UseCase<HomePageData, NoParams> {
  final IHomeRepository repository;

  GetHomePageDataUseCase(this.repository);

  /// 执行用例，获取首页数据
  /// 
  /// 返回 [HomePageData] 包含轮播图、分类和首屏信息流数据
  /// 或者返回 [Failure] 表示获取数据失败
  @override
  Future<Either<Failure, HomePageData>> call(NoParams params) async {
    return await repository.getHomePageData();
  }
}