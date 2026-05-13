import 'package:flutter/material.dart';

import '../components/cart_controller.dart';
import '../components/cart_item_tile.dart';
import '../components/empty_state.dart';
import 'checkout_success.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.cartController,
  });

  static const routeName = '/cart';

  final CartController cartController;

  void _finishPurchase(BuildContext context) {
    if (cartController.items.isEmpty) return;

    cartController.clear();
    Navigator.of(context).pushNamed(CheckoutSuccessScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body: AnimatedBuilder(
        animation: cartController,
        builder: (_, __) {
          if (cartController.items.isEmpty) {
            return const EmptyState(
              icon: Icons.remove_shopping_cart_outlined,
              title: 'Carrinho vazio',
              message: 'Adicione sucos na home para visualizar aqui.',
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartController.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = cartController.items[index];
                    return CartItemTile(
                      item: item,
                      onIncrease: () => cartController.add(item.product),
                      onDecrease: () => cartController.decrease(item.product),
                      onRemove: () => cartController.remove(item.product),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total'),
                        Text(
                          'R\$ ${cartController.totalPrice.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _finishPurchase(context),
                        icon: const Icon(Icons.payments_outlined),
                        label: const Text('Finalizar compra'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
