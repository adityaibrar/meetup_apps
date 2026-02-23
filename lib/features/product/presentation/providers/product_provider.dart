import 'package:flutter/material.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/get_my_products_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';

/// Provider untuk manajemen state produk (marketplace, my products) menggunakan Clean Architecture.
class ProductProvider extends ChangeNotifier {
  final GetProductsUseCase _getProductsUseCase;
  final GetMyProductsUseCase _getMyProductsUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final CreateProductUseCase _createProductUseCase;
  final UpdateProductUseCase _updateProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;

  ProductProvider({
    required GetProductsUseCase getProductsUseCase,
    required GetMyProductsUseCase getMyProductsUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
    required CreateProductUseCase createProductUseCase,
    required UpdateProductUseCase updateProductUseCase,
    required DeleteProductUseCase deleteProductUseCase,
  }) : _getProductsUseCase = getProductsUseCase,
       _getMyProductsUseCase = getMyProductsUseCase,
       _getCategoriesUseCase = getCategoriesUseCase,
       _createProductUseCase = createProductUseCase,
       _updateProductUseCase = updateProductUseCase,
       _deleteProductUseCase = deleteProductUseCase;

  List<dynamic> _products = [];
  List<dynamic> _myProducts = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get products => _products;
  List<dynamic> get myProducts => _myProducts;
  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load semua produk yang tersedia (dengan filter opsional).
  Future<void> loadProducts(
    String token, {
    String? category,
    String? query,
    String? province,
    String? city,
    int? sellerId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getProductsUseCase.call(
      token,
      category: category,
      query: query,
      province: province,
      city: city,
      sellerId: sellerId,
    );

    result.fold(
      (failure) => _error = failure.message,
      (data) => _products = data,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Load produk milik user yang sedang login.
  Future<void> loadMyProducts(String token) async {
    final result = await _getMyProductsUseCase.call(token);
    result.fold(
      (failure) => _error = failure.message,
      (data) => _myProducts = data,
    );
    notifyListeners();
  }

  /// Load daftar kategori produk.
  Future<void> loadCategories() async {
    final result = await _getCategoriesUseCase.call();
    result.fold(
      (failure) => _error = failure.message,
      (data) => _categories = data,
    );
    notifyListeners();
  }

  /// Buat produk baru.
  Future<bool> createProduct(
    String token,
    Map<String, dynamic> data,
    List<String> imagePaths,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _createProductUseCase.call(token, data, imagePaths);

    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Update produk yang sudah ada.
  Future<bool> updateProduct(
    String token,
    int productId,
    Map<String, dynamic> data,
    List<String> newImagePaths,
    List<String> existingImageUrls,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _updateProductUseCase.call(
      token,
      productId,
      data,
      newImagePaths,
      existingImageUrls,
    );

    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Hapus produk.
  Future<bool> deleteProduct(String token, int productId) async {
    final result = await _deleteProductUseCase.call(token, productId);

    return result.fold(
      (failure) {
        _error = failure.message;
        return false;
      },
      (_) {
        _products.removeWhere((p) => p['id'] == productId);
        _myProducts.removeWhere((p) => p['id'] == productId);
        notifyListeners();
        return true;
      },
    );
  }
}
