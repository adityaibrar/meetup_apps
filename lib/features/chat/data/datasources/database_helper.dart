import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../../domain/entities/chat_message.dart';

/// Helper SQLite untuk penyimpanan chat lokal.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'meetup_chat.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE messages(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            server_id TEXT,
            chat_room_id INTEGER,
            sender_id INTEGER,
            content TEXT,
            is_read INTEGER,
            created_at TEXT,
            is_synced INTEGER DEFAULT 1,
            product_info TEXT,
            reply_to_id TEXT,
            reply_to_content TEXT,
            reply_to_sender_name TEXT,
            media_type TEXT,
            media_url TEXT,
            local_media_path TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE messages ADD COLUMN product_info TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE messages ADD COLUMN reply_to_id TEXT');
          await db.execute(
            'ALTER TABLE messages ADD COLUMN reply_to_content TEXT',
          );
          await db.execute(
            'ALTER TABLE messages ADD COLUMN reply_to_sender_name TEXT',
          );
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE messages ADD COLUMN media_type TEXT');
          await db.execute('ALTER TABLE messages ADD COLUMN media_url TEXT');
          await db.execute(
            'ALTER TABLE messages ADD COLUMN local_media_path TEXT',
          );
        }
      },
      onOpen: (db) async {
        await db.delete('messages', where: 'created_at IS NULL');
      },
    );
  }

  Future<void> insertMessage(ChatMessage message) async {
    final db = await database;

    // Check if message exist
    final existingMap = await db.query(
      'messages',
      where: 'server_id = ?',
      whereArgs: [message.id],
      limit: 1,
    );

    if (existingMap.isNotEmpty) {
      final existing = existingMap.first;
      // Preserve media fields
      final newMediaType = message.mediaType ?? existing['media_type'];
      final newMediaUrl = message.mediaUrl ?? existing['media_url'];
      final newLocalPath =
          message.localMediaPath ?? existing['local_media_path'];

      await db.update(
        'messages',
        {
          'chat_room_id': message.chatRoomId,
          'sender_id': message.senderId,
          'content': message.content,
          // Don't overwrite isRead if it's already read locally
          'is_read': (existing['is_read'] == 1 || message.isRead) ? 1 : 0,
          'product_info': message.product != null
              ? jsonEncode(message.product)
              : existing['product_info'],
          'reply_to_id': message.replyToId ?? existing['reply_to_id'],
          'reply_to_content':
              message.replyToContent ?? existing['reply_to_content'],
          'reply_to_sender_name':
              message.replyToSenderName ?? existing['reply_to_sender_name'],
          'media_type': newMediaType,
          'media_url': newMediaUrl,
          'local_media_path': newLocalPath,
        },
        where: 'server_id = ?',
        whereArgs: [message.id],
      );
    } else {
      await db.insert('messages', {
        'server_id': message.id,
        'chat_room_id': message.chatRoomId,
        'sender_id': message.senderId,
        'content': message.content,
        'is_read': message.isRead ? 1 : 0,
        'created_at': message.timestamp.toIso8601String(),
        'product_info': message.product != null
            ? jsonEncode(message.product)
            : null,
        'reply_to_id': message.replyToId,
        'reply_to_content': message.replyToContent,
        'reply_to_sender_name': message.replyToSenderName,
        'media_type': message.mediaType,
        'media_url': message.mediaUrl,
        'local_media_path': message.localMediaPath,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<ChatMessage>> getMessages(
    int chatRoomId,
    int currentUserId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'chat_room_id = ?',
      whereArgs: [chatRoomId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      Map<String, dynamic>? productMap;
      try {
        if (maps[i]['product_info'] != null) {
          productMap = jsonDecode(maps[i]['product_info']);
        }
      } catch (_) {}

      return ChatMessage(
        id: maps[i]['server_id'] ?? maps[i]['id'].toString(),
        chatRoomId: maps[i]['chat_room_id'],
        senderId: maps[i]['sender_id'],
        content: maps[i]['content'],
        timestamp: DateTime.tryParse(maps[i]['created_at']) ?? DateTime.now(),
        isRead: maps[i]['is_read'] == 1,
        isMe: maps[i]['sender_id'] == currentUserId,
        product: productMap,
        replyToId: maps[i]['reply_to_id'],
        replyToContent: maps[i]['reply_to_content'],
        replyToSenderName: maps[i]['reply_to_sender_name'],
        mediaType: maps[i]['media_type'],
        mediaUrl: maps[i]['media_url'],
        localMediaPath: maps[i]['local_media_path'],
      );
    });
  }

  Future<bool> messageExists(String serverId) async {
    final db = await database;
    final res = await db.query(
      'messages',
      where: 'server_id = ?',
      whereArgs: [serverId],
    );
    return res.isNotEmpty;
  }

  Future<void> deleteMessages(int chatRoomId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'chat_room_id = ?',
      whereArgs: [chatRoomId],
    );
  }

  Future<void> deleteMessageByServerId(String serverId) async {
    final db = await database;
    await db.delete('messages', where: 'server_id = ?', whereArgs: [serverId]);
  }

  Future<void> updateMessageReadStatus(String serverId, bool isRead) async {
    final db = await database;
    await db.update(
      'messages',
      {'is_read': isRead ? 1 : 0},
      where: 'server_id = ?',
      whereArgs: [serverId],
    );
  }

  Future<ChatMessage?> getLastMessage(int chatRoomId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'chat_room_id = ?',
      whereArgs: [chatRoomId],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    final map = maps.first;

    Map<String, dynamic>? productMap;
    try {
      if (map['product_info'] != null) {
        productMap = jsonDecode(map['product_info']);
      }
    } catch (_) {}

    return ChatMessage(
      id: map['server_id'] ?? map['id'].toString(),
      chatRoomId: map['chat_room_id'],
      senderId: map['sender_id'],
      content: map['content'],
      isRead: map['is_read'] == 1,
      isMe: false,
      timestamp: DateTime.tryParse(map['created_at']) ?? DateTime.now(),
      product: productMap,
      replyToId: map['reply_to_id'],
      replyToContent: map['reply_to_content'],
      replyToSenderName: map['reply_to_sender_name'],
      mediaType: map['media_type'],
      mediaUrl: map['media_url'],
      localMediaPath: map['local_media_path'],
    );
  }
}
