import 'package:equatable/equatable.dart';

/// Entity ChatMessage — pure Dart.
class ChatMessage extends Equatable {
  final String? id;
  final int senderId;
  final int chatRoomId;
  final String content;
  final bool isMe;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? product;
  final String? senderName;
  final String? senderImage;

  // Reply-to support (WhatsApp-style)
  final String? replyToId;
  final String? replyToContent;
  final String? replyToSenderName;

  const ChatMessage({
    this.id,
    required this.senderId,
    required this.chatRoomId,
    required this.content,
    required this.isMe,
    required this.timestamp,
    this.isRead = false,
    this.product,
    this.senderName,
    this.senderImage,
    this.replyToId,
    this.replyToContent,
    this.replyToSenderName,
  });

  ChatMessage copyWith({
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
    return ChatMessage(
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

  @override
  List<Object?> get props => [
    id,
    senderId,
    chatRoomId,
    content,
    isMe,
    timestamp,
    isRead,
    product,
    senderName,
    senderImage,
    replyToId,
    replyToContent,
    replyToSenderName,
  ];
}
