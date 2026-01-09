import 'package:flutter/foundation.dart';
import '../models/meengle_story.dart';

class StoriesProvider extends ChangeNotifier {
  List<MeengleStory> _stories = [];
  bool _isLoading = false;
  String? _error;

  List<MeengleStory> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStories() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _stories = [
        MeengleStory(
          id: 'story1',
          userId: 'user1',
          mediaUrl: 'https://via.placeholder.com/400x500',
          mediaType: 'image',
          caption: 'Having amazing time at the beach!',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          expiresAt: DateTime.now().add(const Duration(hours: 22)),
          viewCount: 45,
          viewedByUserIds: const [],
        ),
      ];
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> postStory(String userId, String caption) async {
    try {
      final story = MeengleStory(
        id: 'story_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        mediaUrl: '',
        mediaType: 'text',
        caption: caption,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
      _stories.insert(0, story);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> postStoryWithMedia(
    String userId,
    String caption,
    String? imageUrl,
  ) async {
    try {
      final story = MeengleStory(
        id: 'story_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        mediaUrl: imageUrl ?? '',
        mediaType: imageUrl != null ? 'image' : 'text',
        caption: caption,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
      _stories.insert(0, story);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleLikeStory(String storyId) async {
    try {
      final index = _stories.indexWhere((s) => s.id == storyId);
      if (index != -1) {
        final story = _stories[index];
        // Toggle like count (in real app, would call API)
        final newLikeCount = story.likeCount + 1;
        final updatedStory = story.copyWith(likeCount: newLikeCount);
        _stories[index] = updatedStory;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void updateStoryNotification(String storyId, Map<String, dynamic> notification) {
    try {
      final index = _stories.indexWhere((s) => s.id == storyId);
      if (index != -1) {
        final story = _stories[index];
        final type = notification['type'] as String?;
        
        if (type == 'liked') {
          final newLikeCount = story.likeCount + 1;
          _stories[index] = story.copyWith(likeCount: newLikeCount);
        } else if (type == 'viewed') {
          final newViewCount = story.viewCount + 1;
          _stories[index] = story.copyWith(viewCount: newViewCount);
        }
        
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    }
  }
}
