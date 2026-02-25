import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Screen form tambah/edit produk.
class AddProductScreen extends StatefulWidget {
  final dynamic product;
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;

  String _category = 'electronics';
  String _condition = 'used';
  final List<File> _imageFiles = [];
  List<String> _currentImageUrls = [];
  bool _isLoading = false;

  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleCtrl = TextEditingController(text: p?['title'] ?? '');
    _descCtrl = TextEditingController(text: p?['description'] ?? '');
    _priceCtrl = TextEditingController(
      text: p != null ? p['price'].toString() : '',
    );
    if (p != null) {
      _category = p['category'] ?? 'electronics';
      _condition = p['condition'] ?? 'used';
      if (p['images'] != null) {
        _currentImageUrls = List<String>.from(p['images']);
      } else if (p['image_url'] != null && p['image_url'] != '') {
        _currentImageUrls = [p['image_url']];
      }
    }
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      _categories = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
          if (_categories.isNotEmpty && widget.product == null) {
            _category = _categories[0]['slug'];
          }
          if (widget.product != null &&
              !_categories.any(
                (c) => c['slug'] == widget.product['category'],
              )) {
            _categories.add({
              'name': widget.product['category'],
              'slug': widget.product['category'],
            });
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      final int currentCount = _imageFiles.length + _currentImageUrls.length;
      final int remainingSlots = 3 - currentCount;

      if (remainingSlots <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maksimal 3 gambar per produk')),
          );
        }
        return;
      }

      final List<XFile> allowedImages = images.length > remainingSlots
          ? images.sublist(0, remainingSlots)
          : images;

      if (images.length > remainingSlots && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gambar dibatasi maksimal 3. Sisa gambar diabaikan.'),
          ),
        );
      }

      setState(
        () => _imageFiles.addAll(allowedImages.map((x) => File(x.path))),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFiles.isEmpty && _currentImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal satu gambar')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) return;

      List<String> imageUrls = [..._currentImageUrls];
      if (_imageFiles.isNotEmpty) {
        final uploaded = await _apiService.uploadImages(
          token,
          _imageFiles.map((f) => f.path).toList(),
        );
        imageUrls.addAll(uploaded);
      }

      final data = {
        'title': _titleCtrl.text,
        'description': _descCtrl.text,
        'price': double.parse(_priceCtrl.text),
        'category': _category,
        'condition': _condition,
        'image_url': imageUrls.isNotEmpty ? imageUrls[0] : '',
        'images': imageUrls,
      };

      if (widget.product != null) {
        await _apiService.updateProduct(token, widget.product['id'], data);
      } else {
        await _apiService.createProduct(token, data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Produk' : 'Jual Barang')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 36,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 6),
                      Text('Tambah Gambar', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ),

              // Image Preview
              if (_currentImageUrls.isNotEmpty || _imageFiles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ..._currentImageUrls.asMap().entries.map(
                          (e) => _buildImagePreview(
                            image: Image.network(
                              e.value,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.broken_image),
                            ),
                            onRemove: () => setState(
                              () => _currentImageUrls.removeAt(e.key),
                            ),
                          ),
                        ),
                        ..._imageFiles.asMap().entries.map(
                          (e) => _buildImagePreview(
                            image: Image.file(e.value, fit: BoxFit.cover),
                            onRemove: () =>
                                setState(() => _imageFiles.removeAt(e.key)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              AppTextField(
                controller: _titleCtrl,
                labelText: 'Nama Produk',
                prefixIcon: Icons.inventory_2_outlined,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _priceCtrl,
                labelText: 'Harga (Rp)',
                prefixText: 'Rp ',
                prefixIcon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              if (_isLoadingCategories)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _category,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(
                      Icons.category_outlined,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  items: _categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c['slug'] as String,
                          child: Text((c['name'] as String).toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _condition,
                decoration: const InputDecoration(
                  labelText: 'Kondisi',
                  prefixIcon: Icon(
                    Icons.verified_outlined,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                ),
                items: ['new', 'used']
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c == 'new' ? 'Baru' : 'Bekas'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _condition = v!),
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _descCtrl,
                labelText: 'Deskripsi',
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 28),
              AppButton(
                label: isEditing ? 'Update Produk' : 'Jual Sekarang',
                onPressed: _submit,
                isLoading: _isLoading,
                icon: isEditing ? Icons.save : Icons.sell,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview({
    required Widget image,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          width: 90,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox.expand(child: image),
          ),
        ),
        Positioned(
          top: 4,
          right: 14,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }
}
