import 'package:flutter/material.dart';

import 'components/app_theme.dart';
import 'components/cart_controller.dart';
import 'components/store_repository.dart';
import 'screens/cart.dart';
import 'screens/checkout_success.dart';
import 'screens/create_product.dart';
import 'screens/home.dart';
import 'screens/main_nav.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JuiceFlowApp());
}

class JuiceFlowApp extends StatefulWidget {
  const JuiceFlowApp({super.key});

  @override
  State<JuiceFlowApp> createState() => _JuiceFlowAppState();
}

class _JuiceFlowAppState extends State<JuiceFlowApp> {
  late final StoreRepository repository;
  late final CartController cartController;

  @override
  void initState() {
    super.initState();
    repository = StoreRepository();
    cartController = CartController();
  }

  @override
  void dispose() {
    cartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JuiceFlow',
      theme: AppTheme.lightTheme,
      routes: {
        MainNavScreen.routeName: (_) => MainNavScreen(
          repository: repository,
          cartController: cartController,
        ),
        HomeScreen.routeName: (_) => HomeScreen(
          repository: repository,
          cartController: cartController,
        ),
        CartScreen.routeName: (_) => CartScreen(cartController: cartController),
        CreateProductScreen.routeName: (_) => CreateProductScreen(
          repository: repository,
        ),
        CheckoutSuccessScreen.routeName: (_) => const CheckoutSuccessScreen(),
      },
      home: const SplashScreen(),
    );
  }
}


