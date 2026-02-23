import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import 'chat_screen.dart';

/// Screen pencarian user untuk memulai chat baru.
class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).clearSearch();
    });
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (token == null) return;
    await userProvider.searchUsers(token, query);
  }

  Future<void> _startChat(dynamic user) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final chat = Provider.of<ChatProvider>(context, listen: false);
    if (auth.token == null || auth.user == null) return;

    final success = await chat.startChat(
      auth.token!,
      user['id'],
      auth.user!.id,
    );
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            targetUserId: user['id'],
            roomName: user['full_name'] ?? user['username'],
            roomId: chat.currentRoomId!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    // ignore: no_leading_underscores_for_local_identifiers
    final _results = userProvider.searchResults;
    // ignore: no_leading_underscores_for_local_identifiers
    final _isLoading = userProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Cari email atau username...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              hintStyle: TextStyle(fontSize: 14, color: AppColors.textTertiary),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _search),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
          ? const Center(child: Text('Cari user untuk memulai chat'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final user = _results[index];
                final imageUrl = user['image_url'];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primarySurface,
                    backgroundImage: (imageUrl != null && imageUrl != '')
                        ? NetworkImage(imageUrl)
                        : null,
                    child: (imageUrl == null || imageUrl == '')
                        ? Text(
                            user['username'][0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    user['full_name'] ?? user['username'],
                    style: AppTextStyles.labelMedium,
                  ),
                  subtitle: Text(user['email'], style: AppTextStyles.bodySmall),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.message_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    onPressed: () => _startChat(user),
                  ),
                  onTap: () => _startChat(user),
                );
              },
            ),
    );
  }
}
