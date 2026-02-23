import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import 'add_product_screen.dart';
import 'seller_profile_screen.dart';

/// Screen detail produk dengan modern layout.
class ProductDetailScreen extends StatelessWidget {
  final dynamic product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isOwner = auth.user?.id == product['seller']?['id'];
    final images =
        product['images'] as List<dynamic>? ??
        (product['image_url'] != null ? [product['image_url']] : []);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        slivers: [
          // Image Hero
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: images.isNotEmpty
                  ? PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (_, index) => Hero(
                        tag: 'product_${product['id']}',
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Icon(
                              Icons.image,
                              size: 60,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.image,
                        size: 60,
                        color: AppColors.textTertiary,
                      ),
                    ),
            ),
            actions: isOwner
                ? [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddProductScreen(product: product),
                          ),
                        );
                        if (result == true && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.error,
                        ),
                      ),
                      onPressed: () => _confirmDelete(context),
                    ),
                  ]
                : null,
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundPrimary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              transform: Matrix4.translationValues(0, -24, 0),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Text(
                    AppFormatters.currency(product['price']),
                    style: AppTextStyles.price.copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(product['title'] ?? '', style: AppTextStyles.h2),
                  const SizedBox(height: 16),

                  // Tags
                  Wrap(
                    spacing: 8,
                    children: [
                      if (product['category'] != null)
                        Chip(
                          label: Text(
                            (product['category'] as String).toUpperCase(),
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: AppColors.primarySurface,
                          labelStyle: const TextStyle(color: AppColors.primary),
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        ),
                      if (product['condition'] != null)
                        Chip(
                          label: Text(
                            (product['condition'] as String).toUpperCase(),
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: AppColors.accentSurface,
                          labelStyle: const TextStyle(color: AppColors.accent),
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Seller
                  if (product['seller'] != null) ...[
                    Text(
                      'Penjual',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SellerProfileScreen(
                            sellerId: product['seller']['id'],
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primarySurface,
                              child: Text(
                                (product['seller']['username'] ?? '?')[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['seller']['full_name'] ??
                                        product['seller']['username'] ??
                                        '',
                                    style: AppTextStyles.labelMedium,
                                  ),
                                  if (product['seller']['city'] != null)
                                    Text(
                                      product['seller']['city'],
                                      style: AppTextStyles.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  Text(
                    'Deskripsi',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      product['description'] ?? 'Tidak ada deskripsi.',
                      style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom CTA
      bottomSheet: isOwner
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 0.5),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _startChat(context),
                    icon: const Icon(Icons.chat_bubble_outline, size: 20),
                    label: const Text('Chat Penjual'),
                  ),
                ),
              ),
            ),
    );
  }

  void _startChat(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final chat = Provider.of<ChatProvider>(context, listen: false);
    if (auth.token == null || auth.user == null) return;

    final sellerId = product['seller']?['id'];
    if (sellerId == null) return;

    final success = await chat.startChat(auth.token!, sellerId, auth.user!.id);
    if (success && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            targetUserId: sellerId,
            roomName: product['seller']['username'] ?? 'Penjual',
            roomId: chat.currentRoomId!,
            productContext: {
              'id': product['id'],
              'title': product['title'],
              'price': product['price'],
              'image_url': product['image_url'],
            },
          ),
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Produk?'),
        content: const Text('Produk yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              if (auth.token == null) return;
              try {
                await ApiService().deleteProduct(auth.token!, product['id']);
                if (context.mounted) Navigator.pop(context, true);
              } catch (_) {}
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
