import 'package:flutter/material.dart';

import '../components/cart_controller.dart';
import '../components/store_repository.dart';

class ProductDetailScreen extends StatefulWidget {
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

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await widget.repository.getCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  String get _name => (widget.product['nome'] ?? widget.product['name'] ?? '').toString();
  String get _description =>
      (widget.product['descricao'] ?? widget.product['description'] ?? '').toString();
  String get _image => widget.repository.resolveImageUrl(
      (widget.product['imagem'] ?? widget.product['image'] ?? '').toString());
  int? get _categoryId => _toInt(widget.product['categoriaId']);
  double get _price {
    final value = widget.product['preco'] ?? widget.product['price'];
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
    String? selectedCategoryId = _categoryId?.toString();

    final updated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
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
                      DropdownButtonFormField<String>(
                        value: _categories.any((c) => c['id']?.toString() == selectedCategoryId)
                            ? selectedCategoryId
                            : null,
                        decoration: const InputDecoration(labelText: 'Categoria'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Sem categoria')),
                          ..._categories.map((cat) => DropdownMenuItem(
                                value: cat['id']?.toString(),
                                child: Text(cat['nome']?.toString() ?? ''),
                              )),
                        ],
                        onChanged: (val) => setDialogState(() => selectedCategoryId = val),
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

                    final selectedCat = selectedCategoryId == null
                        ? null
                        : _categories.firstWhere(
                            (c) => c['id']?.toString() == selectedCategoryId,
                            orElse: () => {},
                          );

                    final updatedProduct = {
                      ...widget.product,
                      'nome': nameController.text.trim(),
                      'descricao': descriptionController.text.trim(),
                      'preco': double.parse(priceController.text.replaceAll(',', '.')),
                      'imagem': imageController.text.trim(),
                      'categoriaId': int.tryParse(selectedCategoryId ?? ''),
                      if (selectedCat != null && selectedCat['slug'] != null)
                        'categoria': selectedCat['slug'],
                    };

                    try {
                      await widget.repository.updateProduct(updatedProduct);
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
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    imageController.dispose();

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
      await widget.repository.deleteProduct(widget.product['id']?.toString() ?? '');
      if (!context.mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir o produto.')),
      );
    }
  }

  Widget _floatingButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF166534),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: null,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _floatingButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                _floatingButton(
                  icon: Icons.edit_outlined,
                  onTap: () => _editProduct(context),
                ),
                const SizedBox(width: 10),
                _floatingButton(
                  icon: Icons.delete_outline,
                  onTap: () => _deleteProduct(context),
                  iconColor: Colors.red.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF15803D), Color(0xFF166534)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              child: AspectRatio(
                aspectRatio: 1.05,
                child: _image.startsWith('assets')
                    ? Image.asset(
                        _image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.green.shade50,
                          child: const Icon(Icons.local_drink, size: 66),
                        ),
                      )
                    : Image.network(
                        _image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.green.shade50,
                          child: const Icon(Icons.local_drink, size: 66),
                        ),
                      ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -22),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    if (widget.categoryName != null && widget.categoryName!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_drink, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              widget.categoryName!,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'R\$ ${_price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Quantidade',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: _quantity > 1
                                        ? () => setState(() => _quantity--)
                                        : null,
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text(
                                    '$_quantity',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() => _quantity++),
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Sobre o produto',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          for (var i = 0; i < _quantity; i++) {
                            widget.cartController.add(widget.product);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$_quantity item(ns) adicionado(s) ao carrinho.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Adicionar ao carrinho'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
