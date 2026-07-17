import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/skeleton/skeleton_page.dart';
import '../../../../core/widgets/skeleton/skeleton_card.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../data/models/transaction_dto.dart';
import '../../domain/entities/wallet_summary.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/network/core_dio_client.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/stripe_connect_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/connect_account/connect_account_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/connect_account/connect_account_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/quick_connect_sheet.dart';

final GetIt sl = GetIt.instance;

/// 钱包页面
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final ScrollController _scrollController = ScrollController();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  String _transactionType = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  ConnectAccountStatus? _connectStatus;

  @override
  void initState() {
    super.initState();
    // 加载钱包摘要信息
    context.read<WalletBloc>().add(const FetchWalletSummary());
    _refreshConnectStatus();
    // 监听滚动事件，实现无限滚动加载
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<WalletBloc>().state;
      if (state is WalletLoaded &&
          !state.isNoMoreData &&
          state.loadMoreError == null) {
        context.read<WalletBloc>().add(LoadMoreWalletTransactions(
              transactionType: _transactionType,
              startDate: _startDate?.toString().split(' ')[0],
              endDate: _endDate?.toString().split(' ')[0],
            ));
      } else if (state is WalletTransactionsOnly &&
          !state.isNoMoreData &&
          state.loadMoreError == null) {
        context.read<WalletBloc>().add(LoadMoreWalletTransactions(
              transactionType: _transactionType,
              startDate: _startDate?.toString().split(' ')[0],
              endDate: _endDate?.toString().split(' ')[0],
            ));
      }
    }
  }

  // 加载交易记录
  void _loadTransactions() {
    context.read<WalletBloc>().add(FetchWalletTransactions(
          transactionType: _transactionType,
          startDate: _startDate?.toString().split(' ')[0],
          endDate: _endDate?.toString().split(' ')[0],
        ));
  }

  Future<void> _refreshConnectStatus() async {
    try {
      final dataSource =
          StripeConnectRemoteDataSourceImpl(sl<CoreDioClient>().dio);
      final status = await dataSource.getAccountStatus(refresh: true);
      if (mounted) setState(() => _connectStatus = status);
    } catch (_) {
      // 钱包余额不应因 Stripe 临时查询失败而不可用；进入收款账户页仍可手动刷新。
    }
  }

  bool get _needsConnectAttention {
    final status = _connectStatus;
    return status != null &&
        status.status != ConnectStatus.notCreated &&
        status.status != ConnectStatus.active;
  }

  // 选择日期范围
  Future<void> _selectDateRange() async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (pickedRange != null) {
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
      });
      _loadTransactions();
    }
  }

  // 清除筛选条件
  void _clearFilters() {
    setState(() {
      _transactionType = 'all';
      _startDate = null;
      _endDate = null;
    });
    _loadTransactions();
  }

  // 安全的返回处理方法
  void _safeGoBack() {
    try {
      if (context.canPop()) {
        context.pop();
      } else {
        // 路由栈为空时，导航到安全的默认页面
        context.go('/seller');
      }
    } catch (e) {
      // 如果所有方法都失败，使用最后的兜底方案
      context.go('/seller');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).profile_wallet_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _safeGoBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WalletBloc>().add(const RefreshWalletSummary());
              _loadTransactions();
              _refreshConnectStatus();
            },
          ),
        ],
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletSummaryLoaded) {
            // 当摘要加载完成后，自动加载交易记录
            _loadTransactions();
          } else if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(AppLocalizations.of(context)
                      .profile_wallet_error(state.message))),
            );
          } else if (state is WithdrawalSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('提现申请已提交，请耐心等待处理'),
                backgroundColor: AppColors.success,
              ),
            );
            // 刷新余额
            context.read<WalletBloc>().add(const RefreshWalletSummary());
          } else if (state is WithdrawalFailed) {
            if (state.message.contains('绑定收款账户')) {
              // #385 未绑定：弹 sheet 而非跳页
              _showQuickConnectSheet();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('提现失败：${state.message}')),
              );
            }
            // 提现失败后刷新钱包摘要，恢复余额卡片显示
            context.read<WalletBloc>().add(const FetchWalletSummary());
          }
        },
        builder: (context, state) {
          if (state is WalletInitial || state is WalletLoading) {
            return SkeletonPage(
                itemCount: 3, itemBuilder: (_, __) => const SkeletonCard());
          } else if (state is WalletError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)
                      .profile_wallet_occurred_error(state.message)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<WalletBloc>()
                          .add(const FetchWalletSummary());
                    },
                    child:
                        Text(AppLocalizations.of(context).profile_wallet_retry),
                  ),
                ],
              ),
            );
          }

          // 根据状态获取钱包摘要和交易记录
          WalletSummary? walletSummary;
          List<TransactionDto> transactions = [];
          bool isLoadingMore = false;
          String? loadMoreError;

          if (state is WalletSummaryLoaded) {
            walletSummary = state.walletSummary;
          } else if (state is WalletTransactionsLoading) {
            walletSummary = state.walletSummary;
            transactions = state.currentTransactions;
          } else if (state is WalletLoaded) {
            walletSummary = state.walletSummary;
            transactions = state.transactions;
            loadMoreError = state.loadMoreError;
          } else if (state is WalletLoadingMore) {
            walletSummary = state.walletSummary;
            transactions = state.transactions;
            isLoadingMore = true;
          } else if (state is WalletTransactionsOnly) {
            transactions = state.transactions;
            loadMoreError = state.loadMoreError;
          } else if (state is WalletTransactionsLoadingMore) {
            transactions = state.transactions;
            isLoadingMore = true;
          }

          return Column(
            children: [
              // #385 KYC 未完成提醒 banner
              if (_needsConnectAttention) _buildKycBanner(),
              // 钱包摘要信息
              if (walletSummary != null) _buildWalletSummary(walletSummary),

              // 筛选条件
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _transactionType,
                        items: [
                          DropdownMenuItem(
                              value: 'all',
                              child: Text(AppLocalizations.of(context)
                                  .profile_wallet_filter_all)),
                          DropdownMenuItem(
                              value: 'income',
                              child: Text(AppLocalizations.of(context)
                                  .profile_wallet_filter_income)),
                          DropdownMenuItem(
                              value: 'outcome',
                              child: Text(AppLocalizations.of(context)
                                  .profile_wallet_filter_expense)),
                        ],
                        onChanged: (value) {
                          if (value != null && value != _transactionType) {
                            setState(() {
                              _transactionType = value;
                            });
                            _loadTransactions();
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: _selectDateRange,
                    ),
                    if (_startDate != null ||
                        _endDate != null ||
                        _transactionType != 'all')
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearFilters,
                      ),
                  ],
                ),
              ),

              // 日期范围显示
              if (_startDate != null && _endDate != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '${DateFormat('yyyy/MM/dd').format(_startDate!)} - ${DateFormat('yyyy/MM/dd').format(_endDate!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),

              // 交易记录列表
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.receipt_long,
                                    size: 48, color: AppColors.textTertiary),
                                const SizedBox(height: 16),
                                Text(
                                    AppLocalizations.of(context)
                                        .profile_wallet_no_transactions,
                                    style: const TextStyle(
                                        color: AppColors.textTertiary)),
                                if (loadMoreError != null)
                                  const SizedBox(height: 8),
                                if (loadMoreError != null)
                                  Text(
                                    AppLocalizations.of(context)
                                        .profile_wallet_load_failed(
                                            loadMoreError),
                                    style: const TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 12),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 16),
                                if (loadMoreError != null)
                                  ElevatedButton(
                                    onPressed: _loadTransactions,
                                    child: Text(AppLocalizations.of(context)
                                        .profile_wallet_retry),
                                  ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: transactions.length +
                            (isLoadingMore ? 1 : 0) +
                            (loadMoreError != null ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < transactions.length) {
                            return _buildTransactionItem(transactions[index]);
                          } else if (isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child:
                                  Center(child: LoadingIndicator(size: 24.0)),
                            );
                          } else if (loadMoreError != null) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(AppLocalizations.of(context)
                                        .profile_wallet_load_more_failed(
                                            loadMoreError)),
                                    TextButton(
                                      onPressed: () {
                                        context
                                            .read<WalletBloc>()
                                            .add(LoadMoreWalletTransactions(
                                              transactionType: _transactionType,
                                              startDate: _startDate
                                                  ?.toString()
                                                  .split(' ')[0],
                                              endDate: _endDate
                                                  ?.toString()
                                                  .split(' ')[0],
                                            ));
                                      },
                                      child: Text(AppLocalizations.of(context)
                                          .profile_wallet_retry),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // #385 弹快速绑定 sheet，绑定成功后刷新钱包状态
  Future<void> _showQuickConnectSheet() async {
    final dio = sl<CoreDioClient>().dio;
    final dataSource = StripeConnectRemoteDataSourceImpl(dio);
    final bloc = ConnectAccountBloc(dataSource: dataSource)
      ..add(CheckConnectAccountStatus());
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const QuickConnectSheet(),
      ),
    );
    if (!mounted) return;
    if (result == true) {
      await _refreshConnectStatus();
      if (!mounted) return;
      context.read<WalletBloc>().add(const RefreshWalletSummary());
      // 快速绑定只创建账户；必须紧接着打开 Stripe Onboarding，不能让用户卡在“已绑定”。
      context.push('/seller/connect-account');
    }
  }

  // #385 KYC 未完成提醒 banner（pendingVerification 状态时显示）
  Widget _buildKycBanner() {
    final status = _connectStatus;
    final needsInformation = status?.status == ConnectStatus.needsInformation ||
        status?.status == ConnectStatus.restricted;
    final detail = status == null
        ? '请刷新收款账户状态'
        : needsInformation
            ? 'Stripe 需要补充认证资料后才能开通提现'
            : '资料已提交，Stripe 正在审核，暂不可提现';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              detail,
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
          TextButton(
            onPressed: () {
              context.push('/seller/connect-account');
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(needsInformation ? '继续验证' : '查看状态',
                style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // 构建钱包摘要卡片
  Widget _buildWalletSummary(WalletSummary summary) {
    return GlassCard(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      borderRadius: BorderRadius.circular(12),
      tintOpacity: 0.62,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).profile_wallet_account_balance,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${RegionConfig.currencySymbol}${summary.balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context).profile_wallet_pending_amount),
              Text(
                  '${RegionConfig.currencySymbol}${(summary.pendingAmount ?? 0.0).toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context).profile_wallet_total_income),
              Text(
                  '${RegionConfig.currencySymbol}${(summary.totalIncome ?? 0.0).toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          // 未绑定时创建 Stripe Connect 账户；账户未激活时明确引导继续验证。
          if (!summary.bound) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showQuickConnectSheet(),
                icon: const Icon(Icons.link),
                label: const Text('绑定收款账户'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: summary.balance > 0
                    ? () {
                        if (_connectStatus != null &&
                            !_connectStatus!.payoutsEnabled) {
                          context.push('/seller/connect-account');
                          return;
                        }
                        _showWithdrawDialog(summary.balance);
                      }
                    : null,
                icon: const Icon(Icons.account_balance),
                label: Text(
                    _connectStatus != null && !_connectStatus!.payoutsEnabled
                        ? '继续验证后提现'
                        : AppLocalizations.of(context).profile_wallet_withdraw),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 构建交易记录项
  Widget _buildTransactionItem(TransactionDto transaction) {
    final bool isIncome = transaction.type == 'income';
    final Color amountColor = isIncome ? AppColors.success : AppColors.error;
    final String amountText = isIncome
        ? '+${transaction.amount.toStringAsFixed(2)}'
        : '-${transaction.amount.abs().toStringAsFixed(2)}';

    // 交易状态图标
    IconData statusIcon;
    Color statusColor;
    switch (transaction.status) {
      case 'completed':
        statusIcon = Icons.check_circle;
        statusColor = AppColors.success;
        break;
      case 'pending':
        statusIcon = Icons.access_time;
        statusColor = AppColors.warning;
        break;
      case 'failed':
        statusIcon = Icons.error;
        statusColor = AppColors.error;
        break;
      default:
        statusIcon = Icons.help;
        statusColor = AppColors.textTertiary;
    }

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(12),
      tintOpacity: 0.62,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.error.withValues(alpha: 0.1),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: amountColor,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                transaction.description,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              amountText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_dateFormat.format(transaction.date)),
            Row(
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  _getStatusText(transaction.status),
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  // 获取状态文本
  String _getStatusText(String status) {
    final s = AppLocalizations.of(context);
    switch (status) {
      case 'completed':
        return s.profile_wallet_status_completed;
      case 'pending':
        return s.profile_wallet_status_pending;
      case 'failed':
        return s.profile_wallet_status_failed;
      default:
        return s.profile_wallet_status_unknown;
    }
  }

  // 显示交易详情
  void _showTransactionDetails(TransactionDto transaction) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  AppLocalizations.of(context)
                      .profile_wallet_transaction_details,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              _buildDetailRow(
                  AppLocalizations.of(context).profile_wallet_transaction_id,
                  transaction.id),
              _buildDetailRow(
                  AppLocalizations.of(context).profile_wallet_transaction_type,
                  transaction.type == 'income'
                      ? AppLocalizations.of(context)
                          .profile_wallet_transaction_type_income
                      : AppLocalizations.of(context)
                          .profile_wallet_transaction_type_expense),
              _buildDetailRow(
                  AppLocalizations.of(context)
                      .profile_wallet_transaction_amount,
                  '${RegionConfig.currencySymbol}${transaction.amount.abs().toStringAsFixed(2)}'),
              _buildDetailRow(
                  AppLocalizations.of(context)
                      .profile_wallet_transaction_description,
                  transaction.description),
              _buildDetailRow(
                  AppLocalizations.of(context).profile_wallet_transaction_date,
                  _dateFormat.format(transaction.date)),
              _buildDetailRow(
                  AppLocalizations.of(context)
                      .profile_wallet_transaction_status,
                  _getStatusText(transaction.status)),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      Text(AppLocalizations.of(context).profile_wallet_close),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 构建详情行
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // 显示提现对话框
  void _showWithdrawDialog(double availableBalance) {
    final TextEditingController amountController = TextEditingController();
    final walletBloc = context.read<WalletBloc>();
    // 幂等 token：绑定到「本次提现弹窗 = 一次提现意图」，在弹窗打开时生成一次并锁定。
    // 弹窗内的任何重试（连点确认、超时后再点）都复用此 token；只有关闭后重新打开弹窗
    // 才视为新意图换新 token。这样"同一次意图的所有重试沿用同一 token"，根治后端
    // 60s 限频窗口外的重复打款双发（详见后端契约 docs/dev/wallet_seller_api_contract.md）。
    final String idempotencyToken = const Uuid().v4();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).profile_wallet_withdraw),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).profile_wallet_available_balance(
                RegionConfig.currencySymbol,
                availableBalance.toStringAsFixed(2))),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).profile_wallet_withdraw_amount,
                hintText:
                    AppLocalizations.of(context).profile_wallet_withdraw_hint,
                border: const OutlineInputBorder(),
                prefixText: '${RegionConfig.currencySymbol} ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).profile_wallet_withdraw_time,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).profile_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppLocalizations.of(context)
                          .profile_wallet_invalid_amount)),
                );
                return;
              }
              if (amount > availableBalance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppLocalizations.of(context)
                          .profile_wallet_exceed_balance)),
                );
                return;
              }

              Navigator.pop(context);
              // 复用弹窗级 token（见 _showWithdrawDialog 顶部），不在此处新生成。
              walletBloc.add(SubmitWithdrawal(
                amount: amount,
                idempotencyToken: idempotencyToken,
              ));
            },
            child: Text(
                AppLocalizations.of(context).profile_wallet_confirm_withdraw),
          ),
        ],
      ),
    );
  }
}
