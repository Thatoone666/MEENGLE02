import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meengle_flutter/models/meengle_story.dart';
import 'api.dart';

/// Service for managing Meengle Stories
class StoryService {
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiService.authKey);
  }

  /// Create a new story
  Future<MeengleStory> createStory({
    required String userId,
    required String mediaUrl,
    required String mediaType, // 'image' or 'video'
    String? caption,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/stories');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
        'caption': caption,
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MeengleStory.fromJson(data['story']);
    }
    throw Exception('Failed to create story');
  }

  /// Get stories from people user follows
  Future<List<MeengleStory>> getFeedStories(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/stories/feed');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final stories = (data['stories'] as List)
          .map((s) => MeengleStory.fromJson(s))
          .toList();
      return stories;
    }
    return [];
  }

  /// Get user's stories
  Future<List<MeengleStory>> getUserStories(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/stories/user/$userId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final stories = (data['stories'] as List)
          .map((s) => MeengleStory.fromJson(s))
          .toList();
      return stories;
    }
    return [];
  }

  /// Get active stories (not expired)
  Future<List<MeengleStory>> getActiveStories(String userId) async {
    final stories = await getUserStories(userId);
    return stories.where((s) => !s.isExpired).toList();
  }

  /// View story (and record view)
  Future<void> viewStory(String storyId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/stories/$storyId/view');
    await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  /// React to story with emoji
  Future<StoryReaction> reactToStory({
    required String storyId,
    required String userId,
    required String emoji,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/stories/$storyId/react');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'emoji': emoji}),
    );
    
    if (response.statusCode == 200) {
      return StoryReaction(
        userId: userId,
        emoji: emoji,
        reactedAt: DateTime.now(),
      );
    }
    throw Exception('Failed to react to story');
  }

  /// Comment on story
  Future<StoryComment> commentOnStory({
    required String storyId,
    required String userId,
    required String comment,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/stories/$storyId/comment');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'comment': comment}),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return StoryComment.fromJson(data['comment']);
    }
    throw Exception('Failed to comment on story');
  }

  /// Get story comments
  Future<List<StoryComment>> getStoryComments(String storyId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/stories/$storyId/comments');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final comments = (data['comments'] as List)
          .map((c) => StoryComment.fromJson(c))
          .toList();
      return comments;
    }
    return [];
  }

  /// Delete story
  Future<void> deleteStory(String storyId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/stories/$storyId');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete story');
    }
  }

  /// Hide story from profile (but visible to direct messages)
  Future<void> hideStory(String storyId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/stories/$storyId/hide');
    await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  /// Get story reactions
  Future<List<StoryReaction>> getStoryReactions(String storyId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/stories/$storyId/reactions');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reactions = (data['reactions'] as List)
          .map((r) => StoryReaction(
            userId: r['userId'],
            emoji: r['emoji'],
            reactedAt: DateTime.parse(r['reactedAt']),
          ))
          .toList();
      return reactions;
    }
    return [];
  }

  /// Like comment on story
  Future<void> likeStoryComment(String commentId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/stories/comments/$commentId/like');
    await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
