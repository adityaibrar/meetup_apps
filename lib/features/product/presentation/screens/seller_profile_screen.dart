import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../../user/domain/entities/rating_entity.dart';
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
      if (mounted) {
        await Provider.of<UserProvider>(
          context,
          listen: false,
        ).loadUserRatings(token, widget.sellerId);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final auth = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isMyProfile = auth.user?.id == widget.sellerId;
    final fullName = _profile?['full_name'] ?? _profile?['username'] ?? '';
    final username = _profile?['username'] ?? '';
    final city = _profile?['city'];
    final province = _profile?['province'];
    final double averageRating = _profile?['average_rating']?.toDouble() ?? 0.0;
    final int totalReviews = _profile?['total_reviews'] ?? 0;

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
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$averageRating ($totalReviews Ulasan)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _startChat(context),
                              icon: const Icon(
                                Icons.chat_bubble_outline,
                                size: 18,
                              ),
                              label: const Text('Chat'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                foregroundColor: AppColors.primary,
                              ),
                              onPressed: () => _showRatingBottomSheet(context),
                              icon: const Icon(Icons.star_border, size: 18),
                              label: const Text('Beri Nilai'),
                            ),
                          ),
                        ],
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text('Ulasan Pembeli', style: AppTextStyles.h3),
            ),
          ),
          if (userProvider.userRatings.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Text(
                  'Belum ada ulasan.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildReviewItem(userProvider.userRatings[index]);
              }, childCount: userProvider.userRatings.length),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildReviewItem(RatingEntity rating) {
    final raterName =
        rating.rater?.fullName ?? rating.rater?.username ?? 'Pengguna';
    final raterInitial = raterName.isNotEmpty
        ? raterName[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  raterInitial,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      raterName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating.score
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 14,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (rating.review.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(rating.review, style: AppTextStyles.bodyMedium),
          ],
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

  void _showRatingBottomSheet(BuildContext context) {
    int selectedScore = 5;
    final reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 32,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Beri Penilaian', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    'Beri rating kepada penjual ini dan bagikan pengalaman Anda.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < selectedScore
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 40,
                          ),
                          onPressed: () {
                            setSheetState(() => selectedScore = index + 1);
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reviewController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Tulis ulasan pengalaman Anda (opsional)...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final token = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).token;
                        if (token == null) return;

                        Navigator.pop(ctx);

                        final userProvider = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        final messenger = ScaffoldMessenger.of(context);

                        final success = await userProvider.submitRating(
                          token,
                          widget.sellerId,
                          selectedScore,
                          reviewController.text,
                        );

                        if (mounted) {
                          if (success) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Penilaian berhasil dikirim'),
                              ),
                            );
                            _loadData(); // reload data to get updated rating
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  userProvider.errorMessage ??
                                      'Gagal mengirim penilaian',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Kirim Penilaian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
