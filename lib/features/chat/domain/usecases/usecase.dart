/// 不需要参数的用例参数
class NoParams {
  const NoParams();
}

/// UseCase基类接口
///
/// 定义用例的基本契约，要求实现call方法
/// [Type] 返回类型
/// [Params] 参数类型
abstract class UseCase<Type, Params> {
  /// 执行用例
  ///
  /// [params] 执行用例所需的参数
  Type call(Params params);
}

/// 不需要参数且返回Stream的用例基类
/// 
/// [Type] 是流中事件的类型
abstract class StreamUseCase<Type> {
  /// 执行用例
  Stream<Type> call();
} 