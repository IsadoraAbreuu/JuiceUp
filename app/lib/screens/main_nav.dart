import 'package:flutter/material.dart';

import '../components/cart_controller.dart';
import '../components/store_repository.dart';
import 'cart.dart';
import 'create_product.dart';
import 'home.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({
    super.key,
    required this.repository,
    required this.cartController,
    this.initialIndex = 0,
  });

  static const routeName = '/main-nav';

  final StoreRepository repository;
  final CartController cartController;
  final int initialIndex;

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        repository: widget.repository,
        cartController: widget.cartController,
      ),
      CreateProductScreen(repository: widget.repository),
      CartScreen(cartController: widget.cartController),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF166534),
          indicatorColor: Colors.white.withValues(alpha: 0.22),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            return const IconThemeData(color: Colors.white);
          }),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.add_box_outlined), label: 'Novo'),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'Carrinho',
            ),
          ],
        ),
      ),
    );
  }
}
