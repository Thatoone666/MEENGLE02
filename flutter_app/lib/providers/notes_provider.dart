import 'package:flutter/foundation.dart';
import '../models/meengle_note.dart';
import '../services/notes_service.dart';

class NotesProvider extends ChangeNotifier {
  final NotesService _service = NotesService();
  
  List<MeengleNote> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<MeengleNote> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotes(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _notes = await _service.getNotesForUser(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(String targetUserId, String content) async {
    try {
      final note = await _service.postNote(targetUserId, content);
      if (note != null) {
        _notes.insert(0, note);
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> likeNote(String noteId) async {
    try {
      await _service.likeNote(noteId);
      final idx = _notes.indexWhere((n) => n.id == noteId);
      if (idx >= 0) {
        _notes[idx] = _notes[idx].copyWith(likes: _notes[idx].likes + 1);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
