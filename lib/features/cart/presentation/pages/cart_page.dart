import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/i_cart_repository.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/cart_summary_widget.dart';

/// 购物车页面
class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('购物车'),
        actions: [
          // 清空购物车按钮
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.cart.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showClearCartConfirmation(context),
                  tooltip: '清空购物车',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartOperationFailure) {
            // 显示错误消息
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CartOperationSuccess) {
            // 显示成功消息
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CheckoutInitiated) {
            // 导航到结算页面
            _navigateToCheckout(context, state.checkoutPreview);
          }
        },
        builder: (context, state) {
          if (state is CartInitial) {
            // 初始状态，加载购物车
            context.read<CartBloc>().add(const LoadCart());
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartLoading) {
            // 加载中状态
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartLoaded) {
            // 加载成功状态
            return _buildCartContent(context, state.cart);
          } else if (state is CartOperationInProgress) {
            // 操作中状态
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16.0),
                  Text('处理中...'),
                ],
              ),
            );
          } else {
            // 其他状态，显示加载中
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  /// 构建购物车内容
  Widget _buildCartContent(BuildContext context, Cart cart) {
    if (cart.isEmpty) {
      // 空购物车
      return _buildEmptyCart(context);
    }

    // 非空购物车
    return Column(
      children: [
        // 购物车列表
        Expanded(
          child: ListView.builder(
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return CartItemWidget(
                item: item,
                onQuantityChanged: (newQuantity) {
                  context.read<CartBloc>().add(
                        UpdateCartItemQuantity(
                          cartItemId: item.id,
                          newQuantity: newQuantity,
                        ),
                      );
                },
                onRemove: () {
                  context.read<CartBloc>().add(
                        RemoveCartItem(cartItemId: item.id),
                      );
                },
                onProductTap: () {
                  _navigateToProductDetail(context, item.productId);
                },
              );
            },
          ),
        ),
        // 购物车摘要
        CartSummaryWidget(
          summary: cart.summary,
          appliedCoupon: cart.appliedCoupon,
          isCheckoutEnabled: cart.isValidForCheckout,
          onCheckout: () {
            context.read<CartBloc>().add(const ProceedToCheckout());
          },
        ),
      ],
    );
  }

  /// 构建空购物车
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80.0,
            color: Colors.grey,
          ),
          const SizedBox(height: 16.0),
          const Text(
            '购物车是空的',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            '添加商品到购物车开始购物',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: () {
              _navigateToContinueShopping(context);
            },
            child: const Text('继续购物'),
          ),
        ],
      ),
    );
  }

  /// 显示清空购物车确认对话框
  void _showClearCartConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空购物车'),
        content: const Text('确定要清空购物车吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CartBloc>().add(const ClearCart());
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 导航到商品详情页
  void _navigateToProductDetail(BuildContext context, String productId) {
    // 使用导航服务导航到商品详情页
    // 实际实现可能需要依赖注入导航服务
    Navigator.of(context).pushNamed('/product/$productId');
  }

  /// 导航到继续购物
  void _navigateToContinueShopping(BuildContext context) {
    // 返回上一页或导航到首页
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  /// 导航到结算页面
  void _navigateToCheckout(BuildContext context, CheckoutPreview checkoutPreview) {
    // 使用导航服务导航到结算页面
    // 实际实现可能需要依赖注入导航服务
    Navigator.of(context).pushNamed(
      '/checkout',
      arguments: checkoutPreview,
    );
  }
}