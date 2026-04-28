import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/transaction_dto.dart';
import '../../domain/entities/wallet_summary.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    // 加载钱包摘要信息
    context.read<WalletBloc>().add(const FetchWalletSummary());
    // 监听滚动事件，实现无限滚动加载
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<WalletBloc>().state;
      if (state is WalletLoaded && !state.isNoMoreData && state.loadMoreError == null) {
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
              SnackBar(content: Text(AppLocalizations.of(context).profile_wallet_error(state.message))),
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
              // 未绑定收款账户，跳转到 Stripe Connect 绑定页面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请先绑定收款账户，即将跳转...')),
              );
              context.push('/seller/connect-account');
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
            return const Center(child: LoadingIndicator());
          } else if (state is WalletError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context).profile_wallet_occurred_error(state.message)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WalletBloc>().add(const FetchWalletSummary());
                    },
                    child: Text(AppLocalizations.of(context).profile_wallet_retry),
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
                          DropdownMenuItem(value: 'all', child: Text(AppLocalizations.of(context).profile_wallet_filter_all)),
                          DropdownMenuItem(value: 'income', child: Text(AppLocalizations.of(context).profile_wallet_filter_income)),
                          DropdownMenuItem(value: 'outcome', child: Text(AppLocalizations.of(context).profile_wallet_filter_expense)),
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
                    if (_startDate != null || _endDate != null || _transactionType != 'all')
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
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.receipt_long, size: 48, color: AppColors.textTertiary),
                                const SizedBox(height: 16),
                                Text(AppLocalizations.of(context).profile_wallet_no_transactions, style: const TextStyle(color: AppColors.textTertiary)),
                                if (loadMoreError != null) const SizedBox(height: 8),
                                if (loadMoreError != null)
                                  Text(
                                    AppLocalizations.of(context).profile_wallet_load_failed(loadMoreError),
                                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 16),
                                if (loadMoreError != null)
                                  ElevatedButton(
                                    onPressed: _loadTransactions,
                                    child: Text(AppLocalizations.of(context).profile_wallet_retry),
                                  ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: transactions.length + (isLoadingMore ? 1 : 0) + (loadMoreError != null ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < transactions.length) {
                            return _buildTransactionItem(transactions[index]);
                          } else if (isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: LoadingIndicator(size: 24.0)),
                            );
                          } else if (loadMoreError != null) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(AppLocalizations.of(context).profile_wallet_load_more_failed(loadMoreError)),
                                    TextButton(
                                      onPressed: () {
                                        context.read<WalletBloc>().add(LoadMoreWalletTransactions(
                                              transactionType: _transactionType,
                                              startDate: _startDate?.toString().split(' ')[0],
                                              endDate: _endDate?.toString().split(' ')[0],
                                            ));
                                      },
                                      child: Text(AppLocalizations.of(context).profile_wallet_retry),
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

  // 构建钱包摘要卡片
  Widget _buildWalletSummary(WalletSummary summary) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                Text('${RegionConfig.currencySymbol}${(summary.pendingAmount ?? 0.0).toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context).profile_wallet_total_income),
                Text('${RegionConfig.currencySymbol}${(summary.totalIncome ?? 0.0).toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: summary.balance > 0 ? () {
                  _showWithdrawDialog(summary.balance);
                } : null,
                icon: const Icon(Icons.account_balance),
                label: Text(AppLocalizations.of(context).profile_wallet_withdraw),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isEnabled ? null : AppColors.textTertiary,
              ),
            ),
          ],
        ),
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
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
                  AppLocalizations.of(context).profile_wallet_transaction_details,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              _buildDetailRow(AppLocalizations.of(context).profile_wallet_transaction_id, transaction.id),
              _buildDetailRow(AppLocalizations.of(context).profile_wallet_transaction_type, transaction.type == 'income' ? AppLocalizations.of(context).profile_wallet_transaction_type_income : AppLocalizations.of(context).profile_wallet_transaction_type_expense),
              _buildDetailRow(AppLocalizations.of(context).profile_wallet_transaction_amount, '${RegionConfig.currencySymbol}${transaction.amount.abs().toStringAsFixed(2)}'),
              _buildDetailRow(AppLocalizations.of(context).profile_wallet_transaction_description, transaction.description),
              _buildDetailRow(AppLocalizations.of(context).profile_wallet_transaction_date, _dateFormat.format(transaction.date)),
              _buildDetailRow(AppLocalizations.of(context).profile_wallet_transaction_status, _getStatusText(transaction.status)),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context).profile_wallet_close),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).profile_wallet_withdraw),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).profile_wallet_available_balance(RegionConfig.currencySymbol, availableBalance.toStringAsFixed(2))),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).profile_wallet_withdraw_amount,
                hintText: AppLocalizations.of(context).profile_wallet_withdraw_hint,
                border: const OutlineInputBorder(),
                prefixText: '${RegionConfig.currencySymbol} ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  SnackBar(content: Text(AppLocalizations.of(context).profile_wallet_invalid_amount)),
                );
                return;
              }
              if (amount > availableBalance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context).profile_wallet_exceed_balance)),
                );
                return;
              }

              Navigator.pop(context);
              walletBloc.add(SubmitWithdrawal(amount: amount));
            },
            child: Text(AppLocalizations.of(context).profile_wallet_confirm_withdraw),
          ),
        ],
      ),
    );
  }

  // 显示功能未实现提示
  void _showNotImplemented() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).profile_wallet_not_implemented),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
