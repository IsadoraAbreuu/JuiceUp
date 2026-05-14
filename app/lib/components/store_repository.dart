import 'api_client.dart';

class StoreRepository {
  StoreRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  String resolveImageUrl(String url) => _apiClient.resolveImageUrl(url);

  Future<List<Map<String, dynamic>>> getProducts() async {
    final data = await _apiClient.getList('produtos');
    return data
        .map((json) => json as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final data = await _apiClient.getList('categorias');
    return data
        .map((json) => json as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>> createProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    int? categoryId,
    String? categoria,
  }) async {
    final response = await _apiClient.post('produtos', {
      'nome': name,
      'descricao': description,
      'preco': price,
      'imagem': imageUrl,
      'categoriaId': categoryId,
      if (categoria != null) 'categoria': categoria,
    });

    return response;
  }

  Future<Map<String, dynamic>> updateProduct(Map<String, dynamic> product) async {
    final response = await _apiClient.put(
      'produtos/${product['id']}',
      product,
    );
    return response;
  }

  Future<void> deleteProduct(String id) {
    return _apiClient.delete('produtos/$id');
  }
}
