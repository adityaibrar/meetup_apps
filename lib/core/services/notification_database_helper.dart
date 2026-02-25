import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalNotification {
  final int? id;
  final int userId;
  final String title;
  final String body;
  final String type; // e.g. "meetup_followup"
  final String? payload; // e.g {"product_id": 123}
  final bool isRead;
  final DateTime createdAt;

  LocalNotification({
    this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.payload,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'payload': payload,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory LocalNotification.fromMap(Map<String, dynamic> map) {
    return LocalNotification(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      body: map['body'],
      type: map['type'],
      payload: map['payload'],
      isRead: map['is_read'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class NotificationDatabaseHelper {
  static final NotificationDatabaseHelper _instance =
      NotificationDatabaseHelper._internal();
  static Database? _database;

  factory NotificationDatabaseHelper() => _instance;
  NotificationDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'meetup_notifications.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE notifications(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            type TEXT NOT NULL,
            payload TEXT,
            is_read INTEGER DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertNotification(LocalNotification notification) async {
    final db = await database;
    return await db.insert(
      'notifications',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocalNotification>> getNotifications(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) {
      return LocalNotification.fromMap(maps[i]);
    });
  }

  Future<int> getUnreadCount(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> markAsRead(int id) async {
    final db = await database;
    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteNotification(int id) async {
    final db = await database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }
}
