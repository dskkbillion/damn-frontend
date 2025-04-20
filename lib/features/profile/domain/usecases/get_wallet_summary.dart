import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet_summary.dart';
import '../repositories/i_wallet_repository.dart';

/// 获取钱包摘要信息的用例
class GetWalletSummary implements UseCase<WalletSummary, NoParams> {
  final IWalletRepository repository;

  const GetWalletSummary(this.repository);

  @override
  Future<Either<Failure, WalletSummary>> call(NoParams params) {
    return repository.getWalletSummary();
  }
}
