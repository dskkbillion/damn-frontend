import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/transaction_dto.dart';
import '../repositories/i_wallet_repository.dart';

/// 获取钱包交易记录的用例
class GetWalletTransactions implements UseCase<List<TransactionDto>, TransactionsParams> {
  final IWalletRepository repository;

  GetWalletTransactions(this.repository);

  @override
  Future<Either<Failure, List<TransactionDto>>> call(TransactionsParams params) async {
    return await repository.getWalletTransactions(
      page: params.page,
      pageSize: params.pageSize,
      startDate: params.startDate,
      endDate: params.endDate,
      transactionType: params.transactionType,
    );
  }
}

/// 交易记录查询参数
class TransactionsParams extends Equatable {
  final int page;
  final int pageSize;
  final String? startDate;
  final String? endDate;
  final String transactionType;

  const TransactionsParams({
    required this.page,
    required this.pageSize,
    this.startDate,
    this.endDate,
    required this.transactionType,
  });

  @override
  List<Object?> get props => [page, pageSize, startDate, endDate, transactionType];
}
