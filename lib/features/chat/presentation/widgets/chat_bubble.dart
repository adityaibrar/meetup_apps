import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/widgets/video_player_widget.dart';
import 'dart:io';
import '../../domain/entities/chat_message.dart';
import '../../../product/presentation/screens/product_detail_screen.dart';

/// Widget chat bubble dengan swipe-to-reply gesture dan reply reference.
class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final void Function(ChatMessage)? onSwipeReply;

  const ChatBubble({super.key, required this.message, this.onSwipeReply});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  static const _replyThreshold = -60.0;
  bool _hasTriggered = false;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      // Hanya izinkan geser ke kiri
      if (_dragOffset > 0) _dragOffset = 0;
      // Cap max drag
      if (_dragOffset < -100) _dragOffset = -100;
    });

    // Trigger reply saat melewati threshold
    if (_dragOffset <= _replyThreshold && !_hasTriggered) {
      _hasTriggered = true;
      // Haptic feedback
      widget.onSwipeReply?.call(widget.message);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    setState(() {
      _dragOffset = 0;
      _hasTriggered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isMe;

    return GestureDetector(
      onHorizontalDragUpdate: widget.onSwipeReply != null
          ? _onHorizontalDragUpdate
          : null,
      onHorizontalDragEnd: widget.onSwipeReply != null
          ? _onHorizontalDragEnd
          : null,
      child: Stack(
        children: [
          // Reply icon yang muncul saat swipe
          if (_dragOffset < -10)
            Positioned(
              right: isMe ? null : 0,
              left: isMe ? null : null,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                child: Opacity(
                  opacity: (_dragOffset.abs() / _replyThreshold.abs()).clamp(
                    0.0,
                    1.0,
                  ),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.reply_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),

          // Bubble content
          AnimatedContainer(
            duration: _dragOffset == 0
                ? const Duration(milliseconds: 200)
                : Duration.zero,
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                margin: EdgeInsets.only(
                  bottom: 6,
                  left: isMe ? 48 : 0,
                  right: isMe ? 0 : 48,
                ),
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // Product Card (jika ada)
                    if (widget.message.product != null)
                      _buildProductCard(widget.message.product!),

                    // Message Bubble
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: isMe ? AppColors.primaryGradient : null,
                        color: isMe ? null : AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isMe ? 18 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 18),
                        ),
                        border: isMe
                            ? null
                            : Border.all(color: AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Reply Reference ──
                          if (widget.message.replyToContent != null)
                            _buildReplyReference(isMe),

                          // ── Media Rendering ──
                          if (widget.message.mediaType != null &&
                              widget.message.mediaType!.isNotEmpty &&
                              widget.message.mediaType != 'text')
                            _buildMediaContent(),

                          // ── Message Content + Timestamp ──
                          Wrap(
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: [
                              if (widget.message.content.isNotEmpty &&
                                  widget.message.content != '📷 Gambar' &&
                                  widget.message.content != '🎥 Video')
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 8.0,
                                    bottom: 2.0,
                                  ),
                                  child: Text(
                                    widget.message.content,
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontSize: 14.5,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppFormatters.messageTime(
                                        widget.message.timestamp,
                                      ),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isMe
                                            ? Colors.white.withValues(
                                                alpha: 0.7,
                                              )
                                            : AppColors.textTertiary,
                                      ),
                                    ),
                                    if (isMe) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        widget.message.isRead
                                            ? Icons.done_all
                                            : Icons.done,
                                        size: 14,
                                        color: widget.message.isRead
                                            ? Colors.white
                                            : Colors.white.withValues(
                                                alpha: 0.6,
                                              ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reply reference box — accent bar kiri, nama pengirim, preview content.
  Widget _buildReplyReference(bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withValues(alpha: 0.15)
            : AppColors.primarySurface,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isMe
                ? Colors.white.withValues(alpha: 0.6)
                : AppColors.primary,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message.replyToSenderName ?? 'User',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isMe
                  ? Colors.white.withValues(alpha: 0.9)
                  : AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.message.replyToContent ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isMe
                  ? Colors.white.withValues(alpha: 0.7)
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    final mediaType = widget.message.mediaType;
    final url = widget.message.mediaUrl;
    final localPath = widget.message.localMediaPath;

    if (mediaType == null) return const SizedBox();

    Widget content;

    if (mediaType == 'image') {
      if (localPath != null && File(localPath).existsSync()) {
        content = Image.file(File(localPath), fit: BoxFit.cover);
      } else if (url != null) {
        final baseUrl = AppConfig.baseUrl.replaceAll('/api', '');
        content = Image.network(
          '$baseUrl$url',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.broken_image)),
        );
      } else {
        content = const Center(child: CircularProgressIndicator());
      }
    } else if (mediaType == 'video') {
      if (localPath != null && File(localPath).existsSync()) {
        content = VideoPlayerWidget(url: localPath, isLocal: true);
      } else if (url != null) {
        final baseUrl = AppConfig.baseUrl.replaceAll('/api', '');
        content = VideoPlayerWidget(url: '$baseUrl$url', isLocal: false);
      } else {
        content = const Center(child: CircularProgressIndicator());
      }
    } else {
      content = const Icon(Icons.insert_drive_file, size: 48);
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 250, maxWidth: 250),
      margin: EdgeInsets.only(bottom: widget.message.content.isEmpty ? 4 : 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black12,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          content,
          if (localPath == null && url == null)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product['image_url'] != null
                  ? Image.network(
                      product['image_url'],
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.image, size: 48),
                    )
                  : const Icon(
                      Icons.image,
                      size: 48,
                      color: AppColors.textTertiary,
                    ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product['title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppFormatters.currency(product['price']),
                    style: AppTextStyles.price.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
