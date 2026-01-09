/// Chat and Match category models
class ChatCategory {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String color;
  final int messageCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault;

  ChatCategory({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.color,
    this.messageCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
  });

  factory ChatCategory.fromJson(Map<String, dynamic> json) {
    return ChatCategory(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? 'Uncategorized',
      description: json['description'],
      color: json['color'] ?? '#FF6B9A',
      messageCount: json['messageCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'color': color,
      'messageCount': messageCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDefault': isDefault,
    };
  }
}

class MatchCategory {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String color;
  final String icon;
  final int matchCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault;

  MatchCategory({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.color,
    this.icon = '??',
    this.matchCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
  });

  factory MatchCategory.fromJson(Map<String, dynamic> json) {
    return MatchCategory(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? 'Uncategorized',
      description: json['description'],
      color: json['color'] ?? '#FF6B9A',
      icon: json['icon'] ?? '??',
      matchCount: json['matchCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'matchCount': matchCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDefault': isDefault,
    };
  }
}

class CategorizedChat {
  final String chatId;
  final String userId;
  final String otherUserId;
  final String categoryId;
  final DateTime categorizedAt;
  final bool isPinned;

  CategorizedChat({
    required this.chatId,
    required this.userId,
    required this.otherUserId,
    required this.categoryId,
    required this.categorizedAt,
    this.isPinned = false,
  });

  factory CategorizedChat.fromJson(Map<String, dynamic> json) {
    return CategorizedChat(
      chatId: json['chatId'] ?? '',
      userId: json['userId'] ?? '',
      otherUserId: json['otherUserId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categorizedAt: DateTime.parse(json['categorizedAt'] ?? DateTime.now().toIso8601String()),
      isPinned: json['isPinned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'userId': userId,
      'otherUserId': otherUserId,
      'categoryId': categoryId,
      'categorizedAt': categorizedAt.toIso8601String(),
      'isPinned': isPinned,
    };
  }
}

class CategorizedMatch {
  final String matchId;
  final String userId;
  final String otherUserId;
  final String categoryId;
  final DateTime categorizedAt;
  final bool isPinned;
  final String? notes;

  CategorizedMatch({
    required this.matchId,
    required this.userId,
    required this.otherUserId,
    required this.categoryId,
    required this.categorizedAt,
    this.isPinned = false,
    this.notes,
  });

  factory CategorizedMatch.fromJson(Map<String, dynamic> json) {
    return CategorizedMatch(
      matchId: json['matchId'] ?? '',
      userId: json['userId'] ?? '',
      otherUserId: json['otherUserId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categorizedAt: DateTime.parse(json['categorizedAt'] ?? DateTime.now().toIso8601String()),
      isPinned: json['isPinned'] ?? false,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'userId': userId,
      'otherUserId': otherUserId,
      'categoryId': categoryId,
      'categorizedAt': categorizedAt.toIso8601String(),
      'isPinned': isPinned,
      'notes': notes,
    };
  }
}
