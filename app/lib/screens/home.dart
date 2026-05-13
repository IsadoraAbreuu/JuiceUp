import 'package:flutter/material.dart';

import '../components/cart_controller.dart';
import '../components/store_repository.dart';
import '../components/empty_state.dart';
import '../components/juice_gradient_background.dart';
import '../components/product_card.dart';
import 'cart.dart';
import 'product_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.cartController,
  });

  static const routeName = '/home';

  final StoreRepository repository;
  final CartController cartController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;
  String _searchQuery = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        widget.repository.getProducts(),
        widget.repository.getCategories(),
      ]);

      if (!mounted) return;
      setState(() {
        _products = results[0];
        _categories = results[1];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Falha ao carregar dados da API.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Map<int, String> get _categoryMap => {
        for (final category in _categories)
          _toInt(category['id']) ?? 0: (category['nome'] ?? '').toString(),
      };

  List<Map<String, dynamic>> get _filteredProducts {
    final filteredByCategory = _selectedCategoryId == null
        ? _products
        : _products
            .where((p) => _toInt(p['categoriaId']) == _selectedCategoryId)
            .toList();

    if (_searchQuery.trim().isEmpty) return filteredByCategory;

    final query = _searchQuery.toLowerCase();
    return filteredByCategory
        .where(
          (p) => (p['nome'] ?? '').toString().toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> _openProductDetail(Map<String, dynamic> product) async {
    final categoryId = _toInt(product['categoriaId']);
    final result = await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => ProductDetailScreen(
          repository: widget.repository,
          cartController: widget.cartController,
          product: product,
          categoryName: _categoryMap[categoryId],
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: JuiceGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                'Entrega em',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Av. Paulista, 1000 - São Paulo',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://i.pravatar.cc/150?img=12',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar suco...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: AnimatedBuilder(
                      animation: widget.cartController,
                      builder: (_, __) {
                        return Badge(
                          isLabelVisible: widget.cartController.totalItems > 0,
                          label: Text(widget.cartController.totalItems.toString()),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pushNamed(CartScreen.routeName),
                            icon: const Icon(Icons.shopping_cart_checkout),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF0EA5E9)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Combo do Dia',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Peça 2 sucos e ganhe 10% OFF',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_offer, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              if (_categories.isNotEmpty)
                SizedBox(
                  height: 102,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryBubble(
                        label: 'Todos',
                        imageUrl: null,
                        selected: _selectedCategoryId == null,
                        onTap: () => setState(() => _selectedCategoryId = null),
                      ),
                      ..._categories.map(
                        (category) {
                          final id = _toInt(category['id']);
                          final image = _categoryImage(category);
                          return _CategoryBubble(
                            label: (category['nome'] ?? '').toString(),
                            imageUrl: image,
                            selected: _selectedCategoryId == id,
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = _selectedCategoryId == id ? null : id;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (_loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_error != null) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      );
                    }

                    final products = _filteredProducts;
                    if (products.isEmpty) {
                      return const EmptyState(
                        icon: Icons.local_drink_outlined,
                        title: 'Sem sucos por aqui',
                        message: 'Adicione produtos novos para começar suas vendas.',
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _loadData,
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: products.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final categoryId = _toInt(product['categoriaId']);
                          final name = (product['nome'] ?? '').toString();
                          return ProductCard(
                            product: product,
                            categoryName: _categoryMap[categoryId],
                            onTap: () => _openProductDetail(product),
                            onAddToCart: () {
                              widget.cartController.add(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$name adicionado ao carrinho.'),
                                  duration: const Duration(milliseconds: 900),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String? _categoryImage(Map<String, dynamic> category) {
    final ownImage = (category['imagem'] ?? category['image'] ?? '').toString();
    if (ownImage.isNotEmpty) return ownImage;

    final id = _toInt(category['id']);
    if (id == null) return null;

    final product = _products.where((p) => _toInt(p['categoriaId']) == id).firstOrNull;
    final productImage = (product?['imagem'] ?? product?['image'] ?? '').toString();
    if (productImage.isNotEmpty) return productImage;
    return null;
  }
}

class _CategoryBubble extends StatelessWidget {
  const _CategoryBubble({
    required this.label,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 10, bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: SizedBox(
          width: 74,
          child: Column(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? const Color(0xFF16A34A) : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: imageUrl == null
                        ? Container(
                            color: Colors.white,
                            child: const Icon(Icons.local_drink, size: 28),
                          )
                        : Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.white,
                              child: const Icon(Icons.local_drink, size: 28),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
