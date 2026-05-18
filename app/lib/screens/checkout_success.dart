import 'package:flutter/material.dart';
import 'main_nav.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  const CheckoutSuccessScreen({super.key});

  static const routeName = '/checkout-success';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 110, width: 110, decoration: BoxDecoration( color: Colors.green.shade100, shape: BoxShape.circle),
                child: Icon(Icons.check_circle, size: 64, color: Colors.green.shade700),
              ),

              SizedBox(height: 18),

              Text('Compra finalizada!', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),

              SizedBox(height: 10),

              Text('Seu pedido foi enviado com sucesso.', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
              
              SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    MainNavScreen.routeName,
                    (route) => false,
                  );
                },
                icon: Icon(Icons.home_outlined),
                label: Text('Voltar para Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
