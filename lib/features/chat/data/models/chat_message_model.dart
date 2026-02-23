import 'dart:convert';
import '../../domain/entities/chat_message.dart';

/// Model ChatMessage dengan serialization.
class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    super.id,
    required super.senderId,
    required super.chatRoomId,
    required super.content,
    required super.isMe,
    required super.timestamp,
    super.isRead,
    super.product,
    super.senderName,
    super.senderImage,
    super.replyToId,
    super.replyToContent,
    super.replyToSenderName,
  });

  @override
  ChatMessageModel copyWith({
    String? id,
    int? senderId,
    int? chatRoomId,
    String? content,
    bool? isMe,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? product,
    String? senderName,
    String? senderImage,
    String? replyToId,
    String? replyToContent,
    String? replyToSenderName,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      content: content ?? this.content,
      isMe: isMe ?? this.isMe,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      product: product ?? this.product,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      replyToId: replyToId ?? this.replyToId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, int myUserId) {
    // Parse reply-to data — server sekarang kirim flat fields (snapshot)
    String? replyToId;
    String? replyToContent;
    String? replyToSenderName;

    if (json['reply_to_id'] != null) {
      replyToId = json['reply_to_id'].toString();
    }

    // Flat fields dari server (snapshot approach)
    if (json['reply_to_content'] != null) {
      replyToContent = json['reply_to_content'];
    }
    if (json['reply_to_sender_name'] != null) {
      replyToSenderName = json['reply_to_sender_name'];
    }

    // Fallback: nested reply_to object (backward compat)
    if (json['reply_to'] != null && json['reply_to'] is Map) {
      final replyTo = json['reply_to'] as Map<String, dynamic>;
      replyToContent ??= replyTo['content'];
      replyToId ??= replyTo['id']?.toString();
      if (replyTo['sender'] != null && replyTo['sender'] is Map) {
        replyToSenderName ??= replyTo['sender']['username'];
      }
    }

    return ChatMessageModel(
      id: json['id']?.toString(),
      senderId: int.tryParse(json['sender_id'].toString()) ?? 0,
      chatRoomId: int.tryParse(json['chat_room_id'].toString()) ?? 0,
      content: json['content'] ?? '',
      isMe: (int.tryParse(json['sender_id'].toString()) ?? 0) == myUserId,
      isRead: json['is_read'] ?? false,
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      product: json['product'] is Map
          ? json['product'] as Map<String, dynamic>
          : (json['product_info'] != null && json['product_info'] is String
                ? _parseProductInfo(json['product_info'] as String)
                : null),
      senderName: json['sender'] != null ? json['sender']['username'] : null,
      senderImage: json['sender'] != null ? json['sender']['image_url'] : null,
      replyToId: replyToId,
      replyToContent: replyToContent,
      replyToSenderName: replyToSenderName,
    );
  }

  static Map<String, dynamic>? _parseProductInfo(String info) {
    try {
      return jsonDecode(info) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
