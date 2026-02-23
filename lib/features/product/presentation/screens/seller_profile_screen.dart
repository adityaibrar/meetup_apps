import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../widgets/product_card.dart';

/// Screen profil penjual.
class SellerProfileScreen extends StatefulWidget {
  final int sellerId;
  const SellerProfileScreen({super.key, required this.sellerId});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _profile;
  List<dynamic>? _products;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;
    try {
      _profile = await _apiService.getUserProfile(token, widget.sellerId);
      _products = await _apiService.getProducts(
        token,
        sellerId: widget.sellerId,
      );
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final auth = Provider.of<AuthProvider>(context);
    final isMyProfile = auth.user?.id == widget.sellerId;
    final fullName = _profile?['full_name'] ?? _profile?['username'] ?? '';
    final username = _profile?['username'] ?? '';
    final city = _profile?['city'];
    final province = _profile?['province'];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (username.isNotEmpty && username != fullName)
                      Text(
                        '@$username',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundPrimary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((city != null && city.isNotEmpty) ||
                        (province != null && province.isNotEmpty))
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            [city, province]
                                .where((e) => e != null && e.isNotEmpty)
                                .join(', '),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    if (!isMyProfile) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _startChat(context),
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Chat Penjual'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text('Produk yang Dijual', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          if (_products == null || _products!.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 60,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 12),
                    Text('Belum ada produk', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ProductCard(product: _products![index]),
                  childCount: _products!.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _startChat(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final chat = Provider.of<ChatProvider>(context, listen: false);
    if (auth.token == null || auth.user == null) return;
    final success = await chat.startChat(
      auth.token!,
      widget.sellerId,
      auth.user!.id,
    );
    if (success && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            targetUserId: widget.sellerId,
            roomName: _profile?['username'] ?? 'Penjual',
            roomId: chat.currentRoomId!,
          ),
        ),
      );
    }
  }
}
