import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/chat_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/meetup_status_widget.dart';

/// Screen percakapan individual dengan redesign modern.
/// Termasuk fitur reply WhatsApp-style (swipe + preview bar).
class ChatScreen extends StatefulWidget {
  final int targetUserId;
  final String roomName;
  final int roomId;
  final Map<String, dynamic>? productContext;

  const ChatScreen({
    super.key,
    required this.targetUserId,
    required this.roomName,
    required this.roomId,
    this.productContext,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  // Store reference to ChatProvider to safely call leaveRoom in dispose
  ChatProvider? _chatProvider;
  Set<int> _previousReadyUserIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chat = Provider.of<ChatProvider>(context, listen: false);
      chat.addListener(_onChatProviderUpdate);

      if (widget.productContext != null) {
        _sendProductMessage();
      }
    });
  }

  /// Listen for meetup confirmed + partner ready notification.
  void _onChatProviderUpdate() {
    if (!mounted) return;
    final chat = Provider.of<ChatProvider>(context, listen: false);

    if (chat.meetupConfirmed) {
      _showOnGoingDialog();
      chat.resetMeetupState();
      _previousReadyUserIds.clear();
      return;
    }

    final currentReadyIds = chat.meetupReadyUserIds.toSet();
    final partnerId = widget.targetUserId;

    if (currentReadyIds.contains(partnerId) &&
        !_previousReadyUserIds.contains(partnerId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User $partnerId mengajak titik temu!"),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(label: "Lihat", onPressed: () {}),
        ),
      );
    }
    _previousReadyUserIds = currentReadyIds;
  }

  void _showOnGoingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Meetup Confirmed"),
        content: const Text("Meetup is now ON GOING!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _sendProductMessage() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final chat = Provider.of<ChatProvider>(context, listen: false);
    if (auth.user == null) return;
    chat.sendMessage(
      'Halo, saya tertarik dengan produk ini.',
      auth.user!.id,
      product: widget.productContext,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _chatProvider?.removeListener(_onChatProviderUpdate);
    if (_chatProvider != null) {
      _chatProvider!.leaveRoom();
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final chat = Provider.of<ChatProvider>(context, listen: false);
    if (auth.user == null) return;
    chat.sendMessage(text, auth.user!.id);
    _messageController.clear();
  }

  Future<void> _pickMedia(ImageSource source, {required bool isVideo}) async {
    Navigator.pop(context); // clear modal
    final picker = ImagePicker();
    XFile? file;

    if (isVideo) {
      file = await picker.pickVideo(source: source);
    } else {
      file = await picker.pickImage(source: source, imageQuality: 70);
    }

    if (file != null && mounted) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final chat = Provider.of<ChatProvider>(context, listen: false);
      if (auth.user != null) {
        chat.sendMediaMessage(file.path, auth.user!.id);
      }
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AttachmentOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      color: Colors.pinkAccent,
                      onTap: () =>
                          _pickMedia(ImageSource.camera, isVideo: false),
                    ),
                    _AttachmentOption(
                      icon: Icons.image_rounded,
                      label: 'Galeri',
                      color: Colors.purpleAccent,
                      onTap: () =>
                          _pickMedia(ImageSource.gallery, isVideo: false),
                    ),
                    _AttachmentOption(
                      icon: Icons.videocam_rounded,
                      label: 'Video',
                      color: Colors.orangeAccent,
                      onTap: () =>
                          _pickMedia(ImageSource.gallery, isVideo: true),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<ChatProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final isInRoom = chat.isUserInActiveRoom(widget.targetUserId);
    final isOnline = chat.isUserOnline(widget.targetUserId);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primarySurface,
                  child: Text(
                    widget.roomName[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isInRoom
                            ? Colors.greenAccent
                            : AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.roomName,
                    style: AppTextStyles.labelMedium.copyWith(fontSize: 15),
                  ),
                  Text(
                    isInRoom
                        ? 'Sedang di room'
                        : (isOnline ? 'Online' : 'Offline'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isInRoom
                          ? AppColors.primary
                          : (isOnline
                                ? AppColors.success
                                : AppColors.textTertiary),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Meetup Status
          MeetupStatusWidget(
            targetUserId: widget.targetUserId,
            targetUserName: widget.roomName,
            onReadyPressed: () async {
              final error = await chat.toggleMeetupReady(
                auth.token!,
                widget.roomId,
              );
              if (error != null && context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error)));
              }
            },
          ),

          // Product Context (Removed per request)

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                final msg = chat.messages[index];
                final showDate =
                    index == chat.messages.length - 1 ||
                    msg.timestamp.day != chat.messages[index + 1].timestamp.day;

                return Column(
                  children: [
                    if (showDate)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _formatDateSeparator(msg.timestamp),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ChatBubble(
                      message: msg,
                      onSwipeReply: (message) {
                        chat.setReplyTo(message);
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Reply Preview Bar ──
          if (chat.replyingTo != null) _buildReplyPreviewBar(chat),

          // Input Bar
          _buildInputBar(),
        ],
      ),
    );
  }

  /// Reply preview bar — ditampilkan di atas input saat user swipe reply.
  Widget _buildReplyPreviewBar(ChatProvider chat) {
    final reply = chat.replyingTo!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
          left: const BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reply.isMe ? 'Anda' : (reply.senderName ?? 'User'),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reply.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => chat.clearReplyTo(),
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.textTertiary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  /// Input bar dengan borderless TextField.
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Tulis pesan...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    isCollapsed: true,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showAttachmentOptions,
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.attach_file_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Hari ini';
    }
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Kemarin';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
