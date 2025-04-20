import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/transaction_dto.dart';
import '../../domain/entities/wallet_summary.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

final GetIt sl = GetIt.instance;

/// 钱包页面
class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的钱包'),
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
              SnackBar(content: Text('错误: ${state.message}')),
            );
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
                  Text('发生错误: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WalletBloc>().add(const FetchWalletSummary());
                    },
                    child: const Text('重试'),
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
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('全部')),
                          DropdownMenuItem(value: 'income', child: Text('收入')),
                          DropdownMenuItem(value: 'outcome', child: Text('支出')),
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
                    ? const Center(child: Text('暂无交易记录'))
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
                                    Text('加载更多失败: $loadMoreError'),
                                    TextButton(
                                      onPressed: () {
                                        context.read<WalletBloc>().add(LoadMoreWalletTransactions(
                                              transactionType: _transactionType,
                                              startDate: _startDate?.toString().split(' ')[0],
                                              endDate: _endDate?.toString().split(' ')[0],
                                            ));
                                      },
                                      child: const Text('重试'),
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
                const Text(
                  '账户余额',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '¥${summary.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('待结算金额'),
                Text('¥${(summary.pendingAmount ?? 0.0).toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('总收入'),
                Text('¥${(summary.totalIncome ?? 0.0).toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  icon: Icons.currency_exchange,
                  label: '提现',
                  onTap: () => _showNotImplemented(),
                ),
              ],
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
                color: isEnabled ? null : Colors.grey,
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
    final Color amountColor = isIncome ? Colors.green : Colors.red;
    final String amountText = isIncome
        ? '+${transaction.amount.toStringAsFixed(2)}'
        : '-${transaction.amount.abs().toStringAsFixed(2)}';

    // 交易状态图标
    IconData statusIcon;
    Color statusColor;
    switch (transaction.status) {
      case 'completed':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      case 'pending':
        statusIcon = Icons.access_time;
        statusColor = Colors.orange;
        break;
      case 'failed':
        statusIcon = Icons.error;
        statusColor = Colors.red;
        break;
      default:
        statusIcon = Icons.help;
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green[50] : Colors.red[50],
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
    switch (status) {
      case 'completed':
        return '已完成';
      case 'pending':
        return '处理中';
      case 'failed':
        return '失败';
      default:
        return '未知';
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
                  '交易详情',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              _buildDetailRow('交易ID', transaction.id),
              _buildDetailRow('类型', transaction.type == 'income' ? '收入' : '支出'),
              _buildDetailRow('金额', '¥${transaction.amount.abs().toStringAsFixed(2)}'),
              _buildDetailRow('说明', transaction.description),
              _buildDetailRow('日期', _dateFormat.format(transaction.date)),
              _buildDetailRow('状态', _getStatusText(transaction.status)),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('关闭'),
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
                color: Colors.grey,
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

  // 显示功能未实现提示
  void _showNotImplemented() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('该功能暂未实现'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
