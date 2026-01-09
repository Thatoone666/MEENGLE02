import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/emergency_contact.dart';

/// Provider for managing emergency contacts
class EmergencyContactsProvider extends ChangeNotifier {
  List<EmergencyContact> _contacts = [];
  List<EmergencyContact> _favourites = [];
  bool _isLoading = false;
  String? _error;

  List<EmergencyContact> get contacts => _contacts;
  List<EmergencyContact> get favourites => _favourites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load emergency contacts
  Future<void> loadContacts(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/emergency/contacts/$userId'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _contacts = (data['contacts'] as List)
            .map((item) => EmergencyContact.fromJson(item))
            .toList();
        
        _favourites = _contacts.where((c) => c.isFavourite).toList();
        _error = null;
      } else {
        _error = 'Failed to load contacts';
      }
    } catch (e) {
      _error = 'Error loading contacts: $e';
      print(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add emergency contact
  Future<bool> addContact({
    required String userId,
    required String name,
    required String phoneNumber,
    required String email,
    bool isFavourite = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/emergency/contacts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'name': name,
          'phoneNumber': phoneNumber,
          'email': email,
          'isFavourite': isFavourite,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newContact = EmergencyContact.fromJson(data['contact']);
        _contacts.add(newContact);
        
        if (isFavourite) {
          _favourites.add(newContact);
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error adding contact: $e';
      return false;
    }
  }

  /// Toggle favourite status
  Future<bool> toggleFavourite(String contactId) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:5000/api/emergency/contacts/$contactId/favourite'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedContact = EmergencyContact.fromJson(data['contact']);
        
        final index = _contacts.indexWhere((c) => c.id == contactId);
        if (index != -1) {
          _contacts[index] = updatedContact;
          
          if (updatedContact.isFavourite) {
            if (!_favourites.any((c) => c.id == contactId)) {
              _favourites.add(updatedContact);
            }
          } else {
            _favourites.removeWhere((c) => c.id == contactId);
          }
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error updating contact: $e';
      return false;
    }
  }

  /// Delete emergency contact
  Future<bool> deleteContact(String contactId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/api/emergency/contacts/$contactId'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        _contacts.removeWhere((c) => c.id == contactId);
        _favourites.removeWhere((c) => c.id == contactId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error deleting contact: $e';
      return false;
    }
  }

  /// Check if has favourite contacts
  bool get hasFavourites => _favourites.isNotEmpty;

  /// Get favourite count
  int get favouriteCount => _favourites.length;
}
