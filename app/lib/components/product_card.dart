import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    this.categoryName,
  });

  final Map<String, dynamic> product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final String? categoryName;

  String get _name => (product['nome'] ?? product['name'] ?? '').toString();
  String get _image => (product['imagem'] ?? product['image'] ?? '').toString();
  double get _price {
    final value = product['preco'] ?? product['price'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _image.startsWith('assets')
                      ? Image.asset(
                          _image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: Colors.green.shade50,
                              child: const Center(
                                child: Icon(Icons.local_drink, size: 42),
                              ),
                            );
                          },
                        )
                      : Image.network(
                          _image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: Colors.green.shade50,
                              child: const Center(
                                child: Icon(Icons.local_drink, size: 42),
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'R\$ ${_price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (categoryName != null && categoryName!.isNotEmpty)
                          Text(
                            categoryName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: onAddToCart,
                    icon: const Icon(Icons.add_shopping_cart),
                    tooltip: 'Adicionar ao carrinho',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
