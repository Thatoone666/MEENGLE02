import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Local database for offline functionality
class OfflineDatabase {
  static final OfflineDatabase _instance = OfflineDatabase._internal();
  static Database? _database;

  factory OfflineDatabase() {
    return _instance;
  }

  OfflineDatabase._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'meengle_offline.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onUpgrade: _upgradeTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER,
        bio TEXT,
        photos TEXT,
        interests TEXT,
        verificationStatus TEXT,
        trustScore INTEGER,
        lastSyncTime INTEGER,
        createdAt INTEGER
      )
    ''');

    // Matches table
    await db.execute('''
      CREATE TABLE matches (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        matchId TEXT NOT NULL,
        compatibilityScore REAL,
        status TEXT,
        createdAt INTEGER,
        lastInteractionTime INTEGER,
        FOREIGN KEY(userId) REFERENCES users(id)
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        fromUserId TEXT NOT NULL,
        toUserId TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        read INTEGER DEFAULT 0,
        synced INTEGER DEFAULT 0,
        createdAt INTEGER
      )
    ''');

    // Stories table
    await db.execute('''
      CREATE TABLE stories (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        imageUrl TEXT,
        caption TEXT,
        likes INTEGER DEFAULT 0,
        isViewed INTEGER DEFAULT 0,
        createdAt INTEGER,
        expiresAt INTEGER
      )
    ''');

    // Notes table
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        content TEXT NOT NULL,
        likes INTEGER DEFAULT 0,
        replies INTEGER DEFAULT 0,
        createdAt INTEGER,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Circles table
    await db.execute('''
      CREATE TABLE circles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        memberCount INTEGER,
        isJoined INTEGER DEFAULT 0,
        createdAt INTEGER
      )
    ''');

    // Moments table
    await db.execute('''
      CREATE TABLE moments (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        matchId TEXT NOT NULL,
        secondsRemaining INTEGER,
        createdAt INTEGER,
        expiresAt INTEGER,
        status TEXT
      )
    ''');

    // Sync queue for offline changes
    await db.execute('''
      CREATE TABLE syncQueue (
        id TEXT PRIMARY KEY,
        operation TEXT NOT NULL,
        entity TEXT NOT NULL,
        entityId TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Cache metadata
    await db.execute('''
      CREATE TABLE cacheMetadata (
        key TEXT PRIMARY KEY,
        lastSyncTime INTEGER,
        version INTEGER,
        expiryTime INTEGER
      )
    ''');
  }

  Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here
  }

  /// Save user locally
  Future<void> saveUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert(
      'users',
      {...user, 'lastSyncTime': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get user from local database
  Future<Map<String, dynamic>?> getUser(String userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Save message locally
  Future<void> saveMessage(Map<String, dynamic> message) async {
    final db = await database;
    await db.insert(
      'messages',
      {...message, 'createdAt': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get unsynced messages
  Future<List<Map<String, dynamic>>> getUnsyncedMessages() async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'synced = 0',
      orderBy: 'timestamp ASC',
    );
  }

  /// Mark message as synced
  Future<void> markMessageSynced(String messageId) async {
    final db = await database;
    await db.update(
      'messages',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  /// Queue operation for syncing
  Future<void> queueOperation(
    String operation,
    String entity,
    String entityId,
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    await db.insert(
      'syncQueue',
      {
        'id': '${entity}_${entityId}_${DateTime.now().millisecondsSinceEpoch}',
        'operation': operation,
        'entity': entity,
        'entityId': entityId,
        'data': jsonEncode(data),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'synced': 0,
      },
    );
  }

  /// Get all unsynced operations
  Future<List<Map<String, dynamic>>> getUnsyncedOperations() async {
    final db = await database;
    return await db.query(
      'syncQueue',
      where: 'synced = 0',
      orderBy: 'timestamp ASC',
    );
  }

  /// Mark operation as synced
  Future<void> markOperationSynced(String operationId) async {
    final db = await database;
    await db.update(
      'syncQueue',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [operationId],
    );
  }

  /// Clear old cached data
  Future<void> clearExpiredCache() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await db.delete(
      'cacheMetadata',
      where: 'expiryTime < ?',
      whereArgs: [now],
    );
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final db = await database;
    
    final unsyncedMessages = await db.rawQuery(
      'SELECT COUNT(*) as count FROM messages WHERE synced = 0',
    );
    final unsyncedOps = await db.rawQuery(
      'SELECT COUNT(*) as count FROM syncQueue WHERE synced = 0',
    );

    return {
      'unsyncedMessages': (unsyncedMessages.first['count'] as int?) ?? 0,
      'unsyncedOperations': (unsyncedOps.first['count'] as int?) ?? 0,
      'lastSyncTime': await getLastSyncTime(),
      'isSyncing': false,
    };
  }

  /// Get last sync time
  Future<int?> getLastSyncTime() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(lastSyncTime) as time FROM users',
    );
    return (result.first['time'] as int?) ?? 0;
  }

  /// Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

import 'dart:convert';
