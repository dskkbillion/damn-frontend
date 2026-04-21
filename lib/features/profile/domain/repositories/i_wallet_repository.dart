import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/transaction_dto.dart';
import '../entities/wallet_summary.dart';

/// 钱包仓库接口
abstract class IWalletRepository {
  /// 获取钱包摘要信息
  ///
  /// 返回 [WalletSummary] 实体或 [Failure]
  Future<Either<Failure, WalletSummary>> getWalletSummary();

  /// 获取钱包交易记录
  ///
  /// 参数：
  /// * [page] - 页码，默认为1
  /// * [pageSize] - 每页记录数，默认为20
  /// * [startDate] - 开始日期，格式为YYYY-MM-DD
  /// * [endDate] - 结束日期，格式为YYYY-MM-DD
  /// * [transactionType] - 交易类型，可选值：'income', 'outcome', 'all'(默认)
  Future<Either<Failure, List<TransactionDto>>> getWalletTransactions({
    required int page,
    required int pageSize,
    String? startDate,
    String? endDate,
    required String transactionType,
  });

  /// 提交提款申请
  Future<Either<Failure, void>> submitWithdrawal({required double amount});
}
