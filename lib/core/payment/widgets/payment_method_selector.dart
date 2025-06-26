import 'package:flutter/material.dart';
import '../models/payment_models.dart';

/// 支付方式选择器
class PaymentMethodSelector extends StatefulWidget {
  final PaymentMethod? selectedMethod;
  final ValueChanged<PaymentMethod>? onMethodSelected;
  final List<PaymentMethod> availableMethods;
  final EdgeInsetsGeometry? padding;

  const PaymentMethodSelector({
    super.key,
    this.selectedMethod,
    this.onMethodSelected,
    this.availableMethods = const [
      PaymentMethod.alipay,
      PaymentMethod.wechat,
      PaymentMethod.wallet,
    ],
    this.padding,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  PaymentMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.selectedMethod;
  }

  @override
  void didUpdateWidget(PaymentMethodSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMethod != oldWidget.selectedMethod) {
      _selectedMethod = widget.selectedMethod;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择支付方式',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.availableMethods.map((method) => _buildMethodTile(method)),
        ],
      ),
    );
  }

  Widget _buildMethodTile(PaymentMethod method) {
    final isSelected = _selectedMethod == method;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: _getMethodIcon(method),
        title: Text(
          method.displayName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              )
            : null,
        onTap: () {
          setState(() {
            _selectedMethod = method;
          });
          widget.onMethodSelected?.call(method);
        },
      ),
    );
  }

  Widget _getMethodIcon(PaymentMethod method) {
    IconData iconData;
    Color? iconColor;

    switch (method) {
      case PaymentMethod.alipay:
        iconData = Icons.account_balance_wallet;
        iconColor = const Color(0xFF1678FF);
        break;
      case PaymentMethod.wechat:
        iconData = Icons.chat;
        iconColor = const Color(0xFF07C160);
        break;
      case PaymentMethod.wallet:
        iconData = Icons.wallet;
        iconColor = const Color(0xFFFF6B35);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }
} 