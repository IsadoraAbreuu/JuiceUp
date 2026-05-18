import 'package:flutter/material.dart';
import '../components/store_repository.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({
    super.key,
    required this.repository,
  });

  static const routeName = '/create-product';

  final StoreRepository repository;

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _categoryIdController = TextEditingController();

  bool _saving = false;
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await widget.repository.getCategories();
      if (mounted) setState(() { _categories = cats; _loadingCategories = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _categoryIdController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await widget.repository.createProduct(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.replaceAll(',', '.')),
        imageUrl: _imageController.text.trim(),
        categoryId: int.tryParse(_selectedCategoryId ?? ''),
        categoria: _selectedCategoryId == null
            ? null
            : _categories.firstWhere(
                (c) => c['id']?.toString() == _selectedCategoryId,
                orElse: () => {},
              )['slug']?.toString(),
      );

      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        _formKey.currentState?.reset();
        _nameController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _imageController.clear();
        _categoryIdController.clear();
        setState(() => _selectedCategoryId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto criado com sucesso.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível criar o produto.')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar produto'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container( padding: EdgeInsets.all(18),decoration: BoxDecoration( borderRadius: BorderRadius.circular(24), gradient: const LinearGradient( colors: [Color(0xFF15803D), Color(0xFF166534)]),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF166534).withValues(alpha: 0.22), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(width: 54, height: 54, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle,),
                        child: Icon(Icons.local_drink, color: Colors.white, size: 30)),

                      SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Novo suco no cardápio', style: Theme.of(context).textTheme.titleMedium?.copyWith( color: Colors.white, fontWeight: FontWeight.w800)),

                            SizedBox(height: 4),

                            Text('Cadastre um produto com imagem, preço e categoria.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                Container(padding: EdgeInsets.all(16),
                 decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(controller: _nameController, decoration: InputDecoration( labelText: 'Nome do produto', prefixIcon: Icon(Icons.liquor_outlined)),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Informe o nome' : null,
                      ),
                      
                      SizedBox(height: 12),

                      TextFormField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Descrição', prefixIcon: Icon(Icons.notes_outlined)),
                        maxLines: 3,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Informe a descrição' : null,
                      ),

                     SizedBox(height: 12),

                      TextFormField(controller: _priceController, decoration: InputDecoration( labelText: 'Preço',prefixIcon: Icon(Icons.payments_outlined)),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) return 'Preço inválido';
                          return null;
                        },
                      ),

                      SizedBox(height: 12),

                      TextFormField( controller: _imageController,decoration: InputDecoration(labelText: 'URL da imagem',prefixIcon: Icon(Icons.image_outlined)),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Informe a imagem' : null,
                      ),

                      SizedBox(height: 12),

                      _loadingCategories
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : DropdownButtonFormField<String>(
                              value: _selectedCategoryId,
                              decoration: InputDecoration(
                                labelText: 'Categoria (opcional)',
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              items: [
                                DropdownMenuItem(value: null, child: Text('Sem categoria')),
                                ..._categories.map((cat) => DropdownMenuItem(
                                      value: cat['id']?.toString(),
                                      child: Text(cat['nome']?.toString() ?? ''),
                                    )),
                              ],
                              onChanged: (val) => setState(() => _selectedCategoryId = val),
                            ),

                      SizedBox(height: 20),

                      SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF166534),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _saving ? null : _saveProduct,
                          icon: _saving
                              ? SizedBox(height: 18, width: 18,child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(Icons.save),
                          label: Text( _saving ? 'Salvando...' : 'Salvar produto', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}
