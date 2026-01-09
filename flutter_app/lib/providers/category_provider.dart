import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/category.dart';

/// Provider for managing chat and match categories
class CategoryProvider extends ChangeNotifier {
  List<ChatCategory> _chatCategories = [];
  List<MatchCategory> _matchCategories = [];
  List<CategorizedChat> _categorizedChats = [];
  List<CategorizedMatch> _categorizedMatches = [];
  
  bool _isLoading = false;
  String? _error;

  List<ChatCategory> get chatCategories => _chatCategories;
  List<MatchCategory> get matchCategories => _matchCategories;
  List<CategorizedChat> get categorizedChats => _categorizedChats;
  List<CategorizedMatch> get categorizedMatches => _categorizedMatches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load chat categories
  Future<void> loadChatCategories(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/categories/chat/$userId'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _chatCategories = (data['categories'] as List)
            .map((item) => ChatCategory.fromJson(item))
            .toList();
        _error = null;
      } else {
        _error = 'Failed to load chat categories';
      }
    } catch (e) {
      _error = 'Error loading chat categories: $e';
      print(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load match categories
  Future<void> loadMatchCategories(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/categories/match/$userId'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _matchCategories = (data['categories'] as List)
            .map((item) => MatchCategory.fromJson(item))
            .toList();
        _error = null;
      } else {
        _error = 'Failed to load match categories';
      }
    } catch (e) {
      _error = 'Error loading match categories: $e';
      print(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create chat category
  Future<bool> createChatCategory({
    required String userId,
    required String name,
    String? description,
    required String color,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/categories/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'name': name,
          'description': description,
          'color': color,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newCategory = ChatCategory.fromJson(data['category']);
        _chatCategories.add(newCategory);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error creating chat category: $e';
      return false;
    }
  }

  /// Create match category
  Future<bool> createMatchCategory({
    required String userId,
    required String name,
    String? description,
    required String color,
    required String icon,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/categories/match'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'name': name,
          'description': description,
          'color': color,
          'icon': icon,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newCategory = MatchCategory.fromJson(data['category']);
        _matchCategories.add(newCategory);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error creating match category: $e';
      return false;
    }
  }

  /// Update chat category
  Future<bool> updateChatCategory({
    required String categoryId,
    required String name,
    String? description,
    required String color,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:5000/api/categories/chat/$categoryId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': description,
          'color': color,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedCategory = ChatCategory.fromJson(data['category']);
        final index = _chatCategories.indexWhere((c) => c.id == categoryId);
        if (index != -1) {
          _chatCategories[index] = updatedCategory;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error updating chat category: $e';
      return false;
    }
  }

  /// Update match category
  Future<bool> updateMatchCategory({
    required String categoryId,
    required String name,
    String? description,
    required String color,
    required String icon,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:5000/api/categories/match/$categoryId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': description,
          'color': color,
          'icon': icon,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedCategory = MatchCategory.fromJson(data['category']);
        final index = _matchCategories.indexWhere((c) => c.id == categoryId);
        if (index != -1) {
          _matchCategories[index] = updatedCategory;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error updating match category: $e';
      return false;
    }
  }

  /// Delete chat category
  Future<bool> deleteChatCategory(String categoryId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/api/categories/chat/$categoryId'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        _chatCategories.removeWhere((c) => c.id == categoryId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error deleting chat category: $e';
      return false;
    }
  }

  /// Delete match category
  Future<bool> deleteMatchCategory(String categoryId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/api/categories/match/$categoryId'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        _matchCategories.removeWhere((c) => c.id == categoryId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error deleting match category: $e';
      return false;
    }
  }

  /// Categorize chat
  Future<bool> categorizeChatMessage({
    required String chatId,
    required String userId,
    required String otherUserId,
    required String categoryId,
    bool isPinned = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/categories/chat/assign'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chatId': chatId,
          'userId': userId,
          'otherUserId': otherUserId,
          'categoryId': categoryId,
          'isPinned': isPinned,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final categorized = CategorizedChat.fromJson(data['categorized']);
        _categorizedChats.add(categorized);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error categorizing chat: $e';
      return false;
    }
  }

  /// Categorize match
  Future<bool> categorizeMatch({
    required String matchId,
    required String userId,
    required String otherUserId,
    required String categoryId,
    bool isPinned = false,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/categories/match/assign'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'matchId': matchId,
          'userId': userId,
          'otherUserId': otherUserId,
          'categoryId': categoryId,
          'isPinned': isPinned,
          'notes': notes,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final categorized = CategorizedMatch.fromJson(data['categorized']);
        _categorizedMatches.add(categorized);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error categorizing match: $e';
      return false;
    }
  }

  /// Get chats in category
  Future<List<CategorizedChat>> getChatsInCategory(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/categories/chat/$categoryId/chats'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['chats'] as List)
            .map((item) => CategorizedChat.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching chats in category: $e');
      return [];
    }
  }

  /// Get matches in category
  Future<List<CategorizedMatch>> getMatchesInCategory(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/categories/match/$categoryId/matches'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['matches'] as List)
            .map((item) => CategorizedMatch.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching matches in category: $e');
      return [];
    }
  }
}
