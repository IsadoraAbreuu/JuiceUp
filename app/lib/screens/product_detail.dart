import 'package:flutter/material.dart';

import '../components/cart_controller.dart';
import '../components/store_repository.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    super.key,
    required this.repository,
    required this.cartController,
    required this.product,
    this.categoryName,
  });

  final StoreRepository repository;
  final CartController cartController;
  final Map<String, dynamic> product;
  final String? categoryName;

  String get _name => (product['nome'] ?? product['name'] ?? '').toString();
  String get _description =>
      (product['descricao'] ?? product['description'] ?? '').toString();
  String get _image => (product['imagem'] ?? product['image'] ?? '').toString();
  int? get _categoryId => _toInt(product['categoriaId']);
  double get _price {
    final value = product['preco'] ?? product['price'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  Future<void> _editProduct(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: _name);
    final descriptionController = TextEditingController(text: _description);
    final priceController = TextEditingController(text: _price.toStringAsFixed(2));
    final imageController = TextEditingController(text: _image);
    final categoryController = TextEditingController(text: _categoryId?.toString() ?? '');

    final updated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Editar produto'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Informe nome' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    maxLines: 2,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Informe descrição' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Preço'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
                      if (parsed == null || parsed <= 0) return 'Preço inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: imageController,
                    decoration: const InputDecoration(labelText: 'URL imagem'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Informe imagem' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Categoria ID'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final updatedProduct = {
                  ...product,
                  'nome': nameController.text.trim(),
                  'descricao': descriptionController.text.trim(),
                  'preco': double.parse(priceController.text.replaceAll(',', '.')),
                  'imagem': imageController.text.trim(),
                  'categoriaId': int.tryParse(categoryController.text.trim()),
                };

                try {
                  await repository.updateProduct(updatedProduct);
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop(true);
                } catch (_) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Falha ao editar produto.')),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    imageController.dispose();
    categoryController.dispose();

    if (updated == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteProduct(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir produto'),
          content: const Text('Deseja realmente excluir este suco?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) return;

    try {
      await repository.deleteProduct(_toInt(product['id']) ?? 0);
      if (!context.mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir o produto.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produto'),
        actions: [
          IconButton(
            onPressed: () => _editProduct(context),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () => _deleteProduct(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 1.4,
                child: Image.network(
                  _image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.green.shade50,
                    child: const Icon(Icons.local_drink, size: 66),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'R\$ ${_price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (categoryName != null && categoryName!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(categoryName!),
                avatar: const Icon(Icons.category_outlined, size: 18),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              _description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                cartController.add(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produto adicionado ao carrinho.')),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Adicionar ao carrinho'),
            ),
          ],
        ),
      ),
    );
  }
}
