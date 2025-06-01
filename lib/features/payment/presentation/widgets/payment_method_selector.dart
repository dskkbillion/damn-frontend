import 'package:flutter/material.dart';

import '../../../../core/payment/services/payment_service_factory.dart';

class PaymentMethodSelector extends StatefulWidget {
  final String? selectedMethod;
  final ValueChanged<String> onMethodChanged;

  const PaymentMethodSelector({
    Key? key,
    this.selectedMethod,
    required this.onMethodChanged,
  }) : super(key: key);

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  String? _selectedMethod;
  late List<PaymentMethod> _paymentMethods;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.selectedMethod ?? 'alipay';
    _paymentMethods = PaymentServiceFactory.getAvailablePaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '支付方式',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        ...(_paymentMethods.where((method) => method.enabled).map((method) {
          final bool isSelected = _selectedMethod == method.id;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMethod = method.id;
              });
              widget.onMethodChanged(method.id);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isSelected 
                  ? Theme.of(context).primaryColor.withOpacity(0.05) 
                  : Colors.white,
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey,
                  ),
                  const SizedBox(width: 16),
                  
                  // 支付方式图标
                  _buildPaymentIcon(method),
                  const SizedBox(width: 16),
                  
                  Text(
                    method.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList()),
      ],
    );
  }
  
  Widget _buildPaymentIcon(PaymentMethod method) {
    return Image.asset(
      method.icon,
      width: 80,
      height: 40,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 80,
          height: 40,
          decoration: BoxDecoration(
            color: _getPaymentColor(method.id).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            method.name,
            style: TextStyle(
              color: _getPaymentColor(method.id),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
  
  Color _getPaymentColor(String paymentId) {
    switch (paymentId) {
      case 'alipay':
        return Colors.blue;
      case 'wechat':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}