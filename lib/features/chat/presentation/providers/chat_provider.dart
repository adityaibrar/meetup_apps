import 'dart:developer';
import 'package:flutter/material.dart';
import '../../data/datasources/socket_service.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/datasources/encryption_service.dart';
import '../../data/models/chat_message_model.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/delete_chat_usecase.dart';
import '../../domain/usecases/get_my_chats_usecase.dart';
import '../../domain/usecases/get_room_status_usecase.dart';
import '../../domain/usecases/init_private_chat_usecase.dart';
import '../../domain/usecases/toggle_meetup_ready_usecase.dart';
import '../../domain/usecases/upload_chat_media_usecase.dart';
import '../../domain/usecases/download_chat_media_usecase.dart';

/// Provider utama untuk seluruh fitur Chat:
/// WebSocket, messages, meetup, read receipts, E2E encryption.
/// Logic 100% identik dengan original flutter_client_demo.
class ChatProvider extends ChangeNotifier {
  final SocketService _socketService = SocketService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final EncryptionService _encryptionService = EncryptionService();

  final GetMyChatsUseCase _getMyChatsUseCase;
  final InitPrivateChatUseCase _initPrivateChatUseCase;
  final GetRoomStatusUseCase _getRoomStatusUseCase;
  final ToggleMeetupReadyUseCase _toggleMeetupReadyUseCase;
  final DeleteChatUseCase _deleteChatUseCase;
  final UploadChatMediaUseCase _uploadChatMediaUseCase;
  final DownloadChatMediaUseCase _downloadChatMediaUseCase;

  ChatProvider({
    required GetMyChatsUseCase getMyChatsUseCase,
    required InitPrivateChatUseCase initPrivateChatUseCase,
    required GetRoomStatusUseCase getRoomStatusUseCase,
    required ToggleMeetupReadyUseCase toggleMeetupReadyUseCase,
    required DeleteChatUseCase deleteChatUseCase,
    required UploadChatMediaUseCase uploadChatMediaUseCase,
    required DownloadChatMediaUseCase downloadChatMediaUseCase,
  }) : _getMyChatsUseCase = getMyChatsUseCase,
       _initPrivateChatUseCase = initPrivateChatUseCase,
       _getRoomStatusUseCase = getRoomStatusUseCase,
       _toggleMeetupReadyUseCase = toggleMeetupReadyUseCase,
       _deleteChatUseCase = deleteChatUseCase,
       _uploadChatMediaUseCase = uploadChatMediaUseCase,
       _downloadChatMediaUseCase = downloadChatMediaUseCase;

  final List<ChatMessage> _messages = [];
  final Map<int, bool> _userStatus = {}; // userId -> isOnline (app level)
  final Map<int, Map<int, bool>> _roomStatus =
      {}; // roomId -> {userId -> inRoom}

  int? _activeRoomId;
  String? _activeRoomPublicKey; // KEY for E2EE
  bool _isConnected = false;
  String? _authToken;

  // Meetup Negotiation State
  List<int> _meetupReadyUserIds = [];
  bool _meetupConfirmed = false;

  List<ChatMessage> get messages => _messages;
  bool get isConnected => _isConnected;
  int? get activeRoomId => _activeRoomId;
  int? get currentRoomId => _activeRoomId; // Alias for compatibility

  List<int> get meetupReadyUserIds => _meetupReadyUserIds;
  bool get meetupConfirmed => _meetupConfirmed;

  // Reply state management
  ChatMessage? _replyingTo;
  ChatMessage? get replyingTo => _replyingTo;

  void setReplyTo(ChatMessage message) {
    _replyingTo = message;
    notifyListeners();
  }

  void clearReplyTo() {
    _replyingTo = null;
    notifyListeners();
  }

  /// Determine if user is online (app level)
  bool isUserOnline(int userId) {
    return _userStatus[userId] ?? false;
  }

  /// Check if user is currently in a specific room (viewing that chat)
  bool isUserInRoom(int userId, int roomId) {
    return _roomStatus[roomId]?[userId] ?? false;
  }

  /// Check if user is in the currently active room
  bool isUserInActiveRoom(int userId) {
    if (_activeRoomId == null) return false;
    return isUserInRoom(userId, _activeRoomId!);
  }

  void resetMeetupState() {
    _meetupConfirmed = false;
    _meetupReadyUserIds.clear();
    notifyListeners();
  }

  // ── Chat List ──

  List<dynamic> _myChats = [];
  List<dynamic> get myChats => _myChats;

  /// Get My Chats — termasuk decrypt last_message untuk preview.
  /// 3-tier: cek local DB → match by timestamp → decrypt RSA.
  Future<List<dynamic>> getMyChats(String token, int myUserId) async {
    try {
      _authToken = token;
      final result = await _getMyChatsUseCase.call(token);

      return await result.fold(
        (failure) {
          log('Error getting chats: ${failure.message}');
          return [];
        },
        (chats) async {
          // Decrypt last_message for preview
          for (var chat in chats) {
            if (chat['last_message'] != null &&
                (chat['last_message'] as String).isNotEmpty) {
              final lastMsgSenderId = chat['last_message_sender_id'] != null
                  ? int.tryParse(chat['last_message_sender_id'].toString())
                  : 0;

              bool resolved = false;

              // 1. If I am the sender, use local DB
              if (lastMsgSenderId == myUserId && myUserId != 0) {
                final lastLocalMsg = await _dbHelper.getLastMessage(chat['id']);
                if (lastLocalMsg != null) {
                  String displayContent = lastLocalMsg.content;
                  if (lastLocalMsg.mediaType == 'video') {
                    displayContent = '🎥 Video';
                  } else if (lastLocalMsg.mediaType == 'image') {
                    displayContent = '📷 Gambar';
                  }

                  chat['last_message'] = "You: $displayContent";
                  resolved = true;
                }
              }

              // 2. Try matching Local DB by Time
              if (!resolved) {
                if (chat['last_message_at'] != null) {
                  final serverTime = DateTime.parse(
                    chat['last_message_at'],
                  ).toLocal();
                  final lastLocalMsg = await _dbHelper.getLastMessage(
                    chat['id'],
                  );

                  if (lastLocalMsg != null) {
                    final localTime = lastLocalMsg.timestamp.toLocal();
                    final diff = serverTime
                        .difference(localTime)
                        .inSeconds
                        .abs();

                    // If timestamps match (within 2 seconds tolerance)
                    if (diff <= 2) {
                      String displayContent = lastLocalMsg.content;
                      if (lastLocalMsg.mediaType == 'video') {
                        displayContent = '🎥 Video';
                      } else if (lastLocalMsg.mediaType == 'image') {
                        displayContent = '📷 Gambar';
                      }

                      if (lastLocalMsg.isMe) {
                        chat['last_message'] = "You: $displayContent";
                      } else {
                        chat['last_message'] = displayContent;
                      }
                      resolved = true;
                    }
                  }
                }
              }

              // 3. Last Resort: Decrypt (Only if not resolved)
              if (!resolved) {
                try {
                  chat['last_message'] = await _encryptionService.decrypt(
                    chat['last_message'],
                  );
                } catch (e) {
                  // Decryption failed — check if it looks like RSA blob
                  if ((chat['last_message'] as String).length > 50 &&
                      !(chat['last_message'] as String).contains(" ")) {
                    chat['last_message'] = "🔒 Encrypted Message";
                  }
                  // Else leave as is (maybe plain text)
                }
              }
            }
          }

          _myChats = chats;
          notifyListeners();
          return _myChats;
        },
      );
    } catch (e) {
      log('Error getting chats: $e');
      return [];
    }
  }

  // ── Connection ──

  /// Connect to WebSocket (Global)
  void connect(String token, int myUserId) {
    _authToken = token;
    _encryptionService.init(); // Ensure keys are ready
    if (!_isConnected || !_socketService.isSocketOpen) {
      _socketService.connect(
        token,
        (msg) => _handleIncomingMessage(msg, myUserId),
        _onDisconnect,
      );
      _isConnected = true;
    }
  }

  void _onDisconnect() {
    _isConnected = false;
    notifyListeners();
  }

  // ── Start Chat ──

  /// Start/join a chat room — load local msgs, connect WS, join room.
  Future<bool> startChat(String token, int targetUserId, int myUserId) async {
    try {
      _authToken = token;
      final result = await _initPrivateChatUseCase.call(token, targetUserId);

      return await result.fold(
        (failure) {
          log('Error starting chat: ${failure.message}');
          return false;
        },
        (data) async {
          _activeRoomId = data['room_id'];
          _activeRoomPublicKey =
              data['target_public_key']; // Capture Public Key

          // Clear any stale meetup states
          _meetupReadyUserIds.clear();
          _meetupConfirmed = false;

          // Load local messages first
          await _loadLocalMessages(_activeRoomId!, myUserId);

          // Ensure connected
          connect(token, myUserId);

          _socketService.sendMessage({
            'type': 'join_room',
            'chat_room_id': _activeRoomId,
          });

          await _fetchRoomStatus(token, _activeRoomId!);

          // Refresh my chats list to ensure this conversation appears in the Home Screen
          await getMyChats(token, myUserId);

          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      log('Error starting chat core: $e');
      return false;
    }
  }

  /// Load local messages with deduplicate logic.
  Future<void> _loadLocalMessages(int roomId, int myUserId) async {
    _messages.clear();
    try {
      // Local messages are stored DECRYPTED (Plain Text)
      final localMsgs = await _dbHelper.getMessages(roomId, myUserId);

      // De-duplicate local messages
      final uniqueMsgs = <ChatMessage>[];
      final seenIds = <String>{};

      for (var msg in localMsgs) {
        if (msg.id != null && msg.id != '0') {
          if (!seenIds.contains(msg.id)) {
            seenIds.add(msg.id!);
            uniqueMsgs.add(msg);
          }
        } else {
          if (uniqueMsgs.isEmpty ||
              uniqueMsgs.last.content != msg.content ||
              uniqueMsgs.last.timestamp
                      .difference(msg.timestamp)
                      .inSeconds
                      .abs() >
                  2) {
            uniqueMsgs.add(msg);
          }
        }
      }

      _messages.addAll(uniqueMsgs);
    } catch (e) {
      log('Error loading local messages: $e');
    }
    notifyListeners();
  }

  /// Fetch room status from API — parse statuses array lengkap.
  Future<void> _fetchRoomStatus(String token, int roomId) async {
    final result = await _getRoomStatusUseCase.call(token, roomId);
    result.fold(
      (failure) => log('Error fetching room status: ${failure.message}'),
      (data) {
        final statuses = data['statuses'] as List?;
        if (statuses != null) {
          _roomStatus[roomId] ??= {};
          for (final status in statuses) {
            final userId = status['user_id'] as int;
            final inRoom = status['in_room'] as bool;
            final isOnline = status['is_online'] as bool;
            _roomStatus[roomId]![userId] = inRoom;
            _userStatus[userId] = isOnline;
          }
          log('Room status loaded: ${_roomStatus[roomId]}');
        }

        final readyIds = data['ready_user_ids'] as List?;
        if (readyIds != null && _activeRoomId == roomId) {
          _meetupReadyUserIds = List<int>.from(readyIds);
          notifyListeners();
        }
      },
    );
  }

  // ── Send Message ──

  /// Send message — optimistic update, encrypt, update chat list.
  void sendMessage(
    String content,
    int myUserId, {
    Map<String, dynamic>? product,
  }) async {
    if (_activeRoomId == null) return;

    // Capture reply context sebelum clear
    final replyMsg = _replyingTo;

    // Optimistic Update (Plain Text + reply context)
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = ChatMessage(
      id: tempId,
      chatRoomId: _activeRoomId!,
      senderId: myUserId,
      content: content,
      isRead: false,
      isMe: true,
      timestamp: DateTime.now(),
      product: product,
      replyToId: replyMsg?.id,
      replyToContent: replyMsg?.content,
      replyToSenderName: replyMsg?.isMe == true ? 'Anda' : replyMsg?.senderName,
    );

    // Clear reply state setelah capture
    if (_replyingTo != null) {
      _replyingTo = null;
    }

    _messages.insert(0, tempMsg);
    notifyListeners();

    if (content.trim().isNotEmpty) {
      await _dbHelper.insertMessage(tempMsg);
    }

    // Encrypt before sending
    String encryptedContent = content;
    if (_activeRoomPublicKey != null) {
      try {
        encryptedContent = await _encryptionService.encrypt(
          content,
          _activeRoomPublicKey!,
        );
      } catch (e) {
        log("Encryption failed: $e");
      }
    }

    // ** Update Chat List (Home Screen) - Realtime update **
    final chatIndex = _myChats.indexWhere((c) => c['id'] == _activeRoomId);
    if (chatIndex != -1) {
      var chat = _myChats[chatIndex];
      chat['last_message'] = content; // Show plain text in local UI
      chat['last_message_at'] = DateTime.now().toIso8601String();
      _myChats.removeAt(chatIndex);
      _myChats.insert(0, chat);
      notifyListeners();
    }

    final msg = {
      'type': 'chat',
      'chat_room_id': _activeRoomId,
      'content': encryptedContent, // Send ENCRYPTED
      'temp_id': tempId,
      // ignore: use_null_aware_elements
      if (product != null) 'product': product,
      if (replyMsg?.id != null) 'reply_to_id': int.tryParse(replyMsg!.id!) ?? 0,
      if (replyMsg != null) 'reply_to_content': replyMsg.content,
      if (replyMsg != null)
        'reply_to_sender_name': replyMsg.isMe
            ? 'Anda'
            : (replyMsg.senderName ?? 'User'),
    };

    _socketService.sendMessage(msg);
  }

  // ── Send Media Message ──

  Future<void> sendMediaMessage(String filePath, int myUserId) async {
    if (_activeRoomId == null || _authToken == null) return;

    // TODO: implement optimistic UI for media? We'll just wait for upload for now
    final result = await _uploadChatMediaUseCase.call(_authToken!, filePath);
    result.fold((failure) => log('Error uploading media: ${failure.message}'), (
      data,
    ) async {
      final mediaUrl = data['url'];
      final mediaType = data['media_type'];

      // Setel text content buat preview & notif
      final String textContent = mediaType == 'video'
          ? '🎥 Video'
          : '📷 Gambar';

      // After upload, send via WebSocket
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final tempMsg = ChatMessage(
        id: tempId,
        chatRoomId: _activeRoomId!,
        senderId: myUserId,
        content: '',
        isRead: false,
        isMe: true,
        timestamp: DateTime.now(),
        mediaType: mediaType,
        mediaUrl: mediaUrl,
        localMediaPath: filePath,
      );

      _messages.insert(0, tempMsg);
      notifyListeners();

      await _dbHelper.insertMessage(tempMsg);

      // Encrypt
      String encryptedContent = textContent;
      if (_activeRoomPublicKey != null) {
        try {
          encryptedContent = await _encryptionService.encrypt(
            textContent,
            _activeRoomPublicKey!,
          );
        } catch (e) {
          log("Encryption failed: $e");
        }
      }

      // ** Update Chat List (Home Screen) - Realtime update **
      final chatIndex = _myChats.indexWhere((c) => c['id'] == _activeRoomId);
      if (chatIndex != -1) {
        var chat = _myChats[chatIndex];
        chat['last_message'] = textContent; // Show plain text in local UI
        chat['last_message_at'] = DateTime.now().toIso8601String();
        _myChats.removeAt(chatIndex);
        _myChats.insert(0, chat);
        notifyListeners();
      }

      final msg = {
        'type': 'chat',
        'chat_room_id': _activeRoomId,
        'content': encryptedContent,
        'media_type': mediaType,
        'media_url': mediaUrl,
        'temp_id': tempId,
      };

      _socketService.sendMessage(msg);
    });
  }

  // ── Incoming Messages ──

  /// Handle semua incoming WS messages — chat, read_receipt, status, meetup.
  Future<void> _handleIncomingMessage(dynamic msg, int myUserId) async {
    log('Received message: ${msg['type']}');

    if (msg['type'] == 'chat') {
      final messageData = msg['message'];

      // DECRYPT CONTENT BEFORE CREATING OBJECT
      String content = messageData['content'] ?? '';
      try {
        if (messageData['sender_id'] != myUserId) {
          content = await _encryptionService.decrypt(content);
        }
        // If it's my own message, I can't decrypt it (encrypted with other's public key)
        // We rely on Local Persistence. The Echo is mainly for confirmation.
      } catch (e) {
        log("Decryption failed: $e");
      }

      // Update content in map
      messageData['content'] = content;

      var chatMsg = ChatMessageModel.fromJson(messageData, myUserId);

      log(
        'Chat message received: roomId=${chatMsg.chatRoomId}, activeRoom=$_activeRoomId, isMe=${chatMsg.isMe}',
      );

      // 1. Update Active Room Messages
      if (_activeRoomId != null &&
          chatMsg.chatRoomId.toString() == _activeRoomId.toString()) {
        // Match Temp message
        final index = _messages.indexWhere(
          (m) => m.isMe && (m.id?.startsWith('temp_') ?? false),
        );

        if (index != -1) {
          log('Replacing temp message at index $index');
          await _dbHelper.deleteMessageByServerId(_messages[index].id!);

          // ** PRESERVE PLAIN TEXT CONTENT from local temp if it's my message **
          if (chatMsg.isMe) {
            chatMsg = chatMsg.copyWith(
              content: _messages[index].content,
              localMediaPath:
                  _messages[index].localMediaPath, // Preserve local file path
            );
          }

          _messages[index] = chatMsg;
          await _dbHelper.insertMessage(chatMsg); // Insert Plain Text
        } else {
          // New Message
          final isInvalidId = chatMsg.id == '0' || chatMsg.id == null;
          bool isDuplicate = false;
          if (!isInvalidId) {
            isDuplicate = _messages.any((m) => m.id == chatMsg.id);
          }

          if (!isDuplicate) {
            // ** PRESERVE PLAIN TEXT CONTENT from Local DB **
            if (chatMsg.isMe && chatMsg.content.isEmpty) {
              // Ignore empty insert if not needed or at least merge with DB
            }

            _messages.insert(0, chatMsg);
            if (chatMsg.content.trim().isNotEmpty || chatMsg.mediaUrl != null) {
              await _dbHelper.insertMessage(chatMsg);
            }
          } else {
            // Jika sudah ada (isDuplicate), maka perbarui dari server tanpa merusak localMediaPath
            final idx = _messages.indexWhere((m) => m.id == chatMsg.id);
            if (idx != -1) {
              final existingMsg = _messages[idx];
              chatMsg = chatMsg.copyWith(
                content: existingMsg.content.isNotEmpty
                    ? existingMsg.content
                    : chatMsg.content,
                localMediaPath: existingMsg.localMediaPath, // <--- INI PENTING!
                mediaUrl: chatMsg.mediaUrl ?? existingMsg.mediaUrl,
                mediaType: chatMsg.mediaType ?? existingMsg.mediaType,
              );
              _messages[idx] = chatMsg;
              await _dbHelper.insertMessage(chatMsg);
            }
          }
        }
        notifyListeners();

        // ── Download Media if necessary ──
        if (chatMsg.mediaUrl != null &&
            chatMsg.mediaUrl!.isNotEmpty &&
            !chatMsg.isMe) {
          _downloadChatMediaUseCase.call(chatMsg.mediaUrl!).then((res) {
            res.fold((failure) => log('Download error: ${failure.message}'), (
              localPath,
            ) async {
              final idx = _messages.indexWhere((m) => m.id == chatMsg.id);
              if (idx != -1) {
                _messages[idx] = _messages[idx].copyWith(
                  localMediaPath: localPath,
                );
                await _dbHelper.insertMessage(_messages[idx]);
                notifyListeners();

                // Trigger 'read' event ke WebSocket karena media sudah selesai diunduh dan diputar/ditampilkan.
                // Hal ini akan memicu backend u/ menghapus file media dari Server.
                if (chatMsg.id != null &&
                    chatMsg.id!.isNotEmpty &&
                    !chatMsg.id!.startsWith('temp')) {
                  _socketService.sendMessage({
                    'type': 'read',
                    'message_id': int.tryParse(chatMsg.id!) ?? 0,
                    'chat_room_id': chatMsg.chatRoomId,
                  });
                }
              }
            });
          });
        }
      }

      // ** 2. Update Chat List — realtime update **
      final chatIndex = _myChats.indexWhere(
        (c) => c['id'] == chatMsg.chatRoomId,
      );

      String displayContent = chatMsg.content;
      if (chatMsg.mediaType == 'video') {
        displayContent = '🎥 Video';
      } else if (chatMsg.mediaType == 'image') {
        displayContent = '📷 Gambar';
      }

      if (chatIndex != -1) {
        var chat = _myChats[chatIndex];
        chat['last_message'] = displayContent;
        chat['last_message_at'] = chatMsg.timestamp.toIso8601String();

        if (_activeRoomId != chatMsg.chatRoomId && !chatMsg.isMe) {
          int currentCount = 0;
          if (chat['unread_count'] != null) {
            currentCount = chat['unread_count'] as int;
          }
          chat['unread_count'] = currentCount + 1;
        }

        _myChats.removeAt(chatIndex);
        _myChats.insert(0, chat);
        notifyListeners();
      } else {
        // New chat — insert placeholder and refresh
        _myChats.insert(0, {
          'id': chatMsg.chatRoomId,
          'name': chatMsg.senderName ?? 'New Chat',
          'last_message': displayContent,
          'last_message_at': chatMsg.timestamp.toIso8601String(),
          'unread_count': chatMsg.isMe ? 0 : 1,
          'other_user_id': chatMsg.senderId == myUserId ? 0 : chatMsg.senderId,
          'other_username': chatMsg.senderName,
          'other_image_url': chatMsg.senderImage,
        });
        notifyListeners();
        if (_authToken != null) {
          getMyChats(_authToken!, myUserId);
        }
      }
    } else if (msg['type'] == 'read_receipt') {
      final messageId = msg['message_id'];
      final index = _messages.indexWhere((m) => m.id == messageId.toString());
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(isRead: true);
        notifyListeners();
        await _dbHelper.updateMessageReadStatus(messageId.toString(), true);
      }
    } else if (msg['type'] == 'user_status') {
      final userId = msg['user_id'] as int;
      final isOnline = msg['is_online'] as bool;
      _userStatus[userId] = isOnline;
      notifyListeners();
    } else if (msg['type'] == 'room_status') {
      final userId = msg['user_id'] as int;
      final roomId = msg['chat_room_id'] as int;
      final inRoom = (msg['in_room'] ?? false) as bool;
      _roomStatus[roomId] ??= {};
      _roomStatus[roomId]![userId] = inRoom;
      notifyListeners();
    } else if (msg['type'] == 'online_users_list') {
      final userIds = msg['user_ids'];
      if (userIds != null && userIds is List) {
        for (final userId in userIds) {
          _userStatus[userId as int] = true;
        }
        notifyListeners();
      }
    } else if (msg['type'] == 'meetup_update') {
      final roomId = msg['chat_room_id'] as int;
      final readyUserIDs = List<int>.from(msg['ready_user_ids'] ?? []);
      if (_activeRoomId == roomId) {
        _meetupReadyUserIds = readyUserIDs;
        notifyListeners();
      }
      _updateChatListForMeetup(
        roomId,
        readyUserIDs.isNotEmpty
            ? 'Ajakan Meetup 🤝'
            : 'Membatalkan Ajakan Meetup',
        readyUserIDs.contains(myUserId),
      );
    } else if (msg['type'] == 'meetup_confirmed') {
      final roomId = msg['chat_room_id'] as int;
      if (_activeRoomId == roomId) {
        _meetupConfirmed = true;
        _meetupReadyUserIds.clear();
        notifyListeners();
      }
      _updateChatListForMeetup(roomId, 'Meetup telah disepakati 🎉', false);
    }
  }

  void _updateChatListForMeetup(
    int roomId,
    String messageContent,
    bool isMeAction,
  ) {
    final chatIndex = _myChats.indexWhere((c) => c['id'] == roomId);
    if (chatIndex != -1) {
      var chat = _myChats[chatIndex];
      chat['last_message'] = messageContent;
      chat['last_message_at'] = DateTime.now().toIso8601String();

      if (_activeRoomId != roomId && !isMeAction) {
        int currentCount = 0;
        if (chat['unread_count'] != null) {
          currentCount = chat['unread_count'] as int;
        }
        chat['unread_count'] = currentCount + 1;
      }

      _myChats.removeAt(chatIndex);
      _myChats.insert(0, chat);
      notifyListeners();
    }
  }

  // ── Meetup ──

  Future<String?> toggleMeetupReady(String token, int roomId) async {
    final result = await _toggleMeetupReadyUseCase.call(token, roomId);
    return result.fold((failure) {
      log('Error toggling meetup ready: ${failure.message}');
      return failure.message;
    }, (_) => null);
  }

  // ── Leave Room ──

  void leaveRoom() {
    final roomToLeave = _activeRoomId;
    if (_isConnected && roomToLeave != null) {
      _socketService.sendMessage({
        'type': 'leave_room',
        'chat_room_id': roomToLeave,
      });
    }
    Future.microtask(() {
      _activeRoomId = null;
      _activeRoomPublicKey = null;
      _messages.clear();
      notifyListeners();
    });
  }

  // ── Delete Chat ──

  Future<bool> deleteChat(String token, int roomId) async {
    final result = await _deleteChatUseCase.call(token, roomId);
    return await result.fold(
      (failure) {
        log('Error deleting chat: ${failure.message}');
        return false;
      },
      (_) async {
        await _dbHelper.deleteMessages(roomId);
        _roomStatus.remove(roomId);
        if (_activeRoomId == roomId) {
          _activeRoomId = null;
          _messages.clear();
        }

        // Update the list state
        _myChats.removeWhere((chat) => chat['id'] == roomId);

        notifyListeners();
        return true;
      },
    );
  }

  void disconnect() {
    _socketService.disconnect();
    _isConnected = false;
  }
}
