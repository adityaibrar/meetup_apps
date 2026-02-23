import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/chat_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'chat_screen.dart';
import 'search_user_screen.dart';

/// Screen daftar chat — modern clean design.
/// Logic identik dengan original HomeScreen: load chats, swipe delete, navigate.
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final chat = Provider.of<ChatProvider>(context, listen: false);
    final token = auth.token;
    final user = auth.user;

    if (token != null && user != null) {
      chat.getMyChats(token, user.id);
      // Ensure WebSocket connection is established
      chat.connect(token, user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats', style: AppTextStyles.h2),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.search, size: 20),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchUserScreen()),
              );
              _loadChats(); // Refresh
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final chats = chatProvider.myChats;

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Belum ada percakapan', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    'Cari user untuk mulai chat',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadChats(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chats.length,
              separatorBuilder: (_, _) => const Padding(
                padding: EdgeInsets.only(left: 80),
                child: Divider(height: 1),
              ),
              itemBuilder: (context, index) {
                final chat = chats[index];
                final otherUser = {
                  'id': chat['other_user_id'],
                  'username': chat['other_username'],
                  'image_url': chat['other_image_url'],
                };
                final imageUrl = otherUser['image_url'];
                final unreadCount = chat['unread_count'] ?? 0;

                return Dismissible(
                  key: Key('chat_${chat['id']}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: AppColors.error,
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text("Hapus Chat"),
                        content: const Text(
                          "Yakin ingin menghapus percakapan ini?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text("Batal"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text(
                              "Hapus",
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    final auth = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    if (auth.token != null) {
                      final success = await chatProvider.deleteChat(
                        auth.token!,
                        chat['id'],
                      );
                      if (success) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Chat dihapus")),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Gagal menghapus chat"),
                            ),
                          );
                        }
                        _loadChats(); // Reload to restore item if failed
                      }
                    }
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primarySurface,
                          backgroundImage: (imageUrl != null && imageUrl != "")
                              ? NetworkImage(imageUrl as String)
                              : null,
                          child: (imageUrl == null || imageUrl == "")
                              ? Text(
                                  (otherUser['username'] != null &&
                                          (otherUser['username'] as String)
                                              .isNotEmpty)
                                      ? (otherUser['username'] as String)[0]
                                            .toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                )
                              : null,
                        ),
                        if (chatProvider.isUserOnline(otherUser['id'] ?? 0))
                          Positioned(
                            bottom: 1,
                            right: 1,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      chat['name'] ?? otherUser['username'] ?? 'Unknown User',
                      style: AppTextStyles.labelMedium,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        chat['last_message'] ?? 'Belum ada pesan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: unreadCount > 0
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppFormatters.chatDate(chat['last_message_at']),
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    onTap: () async {
                      final auth = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      if (auth.token == null || auth.user == null) return;

                      await chatProvider.startChat(
                        auth.token!,
                        otherUser['id'],
                        auth.user!.id,
                      );

                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            targetUserId: otherUser['id'],
                            roomName:
                                chat['name'] ?? otherUser['username'] ?? 'User',
                            roomId: chat['id'],
                          ),
                        ),
                      ).then((_) => _loadChats()); // Refresh on return
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
