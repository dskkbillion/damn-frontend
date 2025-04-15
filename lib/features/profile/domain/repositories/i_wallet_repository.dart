import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/wallet_summary.dart';

/// 钱包仓库接口
abstract class IWalletRepository {
  /// 获取钱包摘要信息
  ///
  /// 返回 [WalletSummary] 实体或 [Failure]
  Future<Either<Failure, WalletSummary>> getWalletSummary();
}
