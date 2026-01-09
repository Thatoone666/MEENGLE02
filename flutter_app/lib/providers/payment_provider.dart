import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/spotlight_service.dart';
import '../services/socket_service.dart';
import '../models/meengle_spotlight.dart';

class PaymentProvider extends ChangeNotifier {
  final SpotlightService _spotlightService = SpotlightService();
  final SocketService _socketService = SocketService();
  
  MeengleSpotlight? _activeSpotlight;
  List<MeengleSpotlight> _paymentHistory = [];
  bool _isLoading = false;
  String? _error;
  bool _isProcessing = false;
  String _paymentStatus = 'idle'; // idle, processing, success, failed
  StreamSubscription? _paymentStatusListener;

  MeengleSpotlight? get activeSpotlight => _activeSpotlight;
  List<MeengleSpotlight> get paymentHistory => _paymentHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isProcessing => _isProcessing;
  String get paymentStatus => _paymentStatus;

  /// Load the user's active spotlight
  Future<void> loadActiveSpotlight(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _activeSpotlight = await _spotlightService.getUserActiveSpotlight(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _activeSpotlight = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load payment history
  Future<void> loadPaymentHistory(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _paymentHistory = await _spotlightService.getSpotlightHistory(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _paymentHistory = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Purchase a spotlight tier with Stripe payment
  Future<bool> purchaseSpotlight({
    required String userId,
    required SpotlightTier tier,
  }) async {
    try {
      _isProcessing = true;
      _paymentStatus = 'processing';
      _error = null;
      notifyListeners();

      // Listen to real-time payment status updates via Socket
      _listenToPaymentStatus();

      // Create payment intent on backend
      final spotlight = await _spotlightService.purchaseSpotlight(
        userId: userId,
        tier: tier,
      );

      // Emit Socket event for real-time notification
      _socketService.socket?.emit('payment:completed', {
        'userId': userId,
        'tier': tier.label,
        'amount': _getTierPrice(tier),
        'timestamp': DateTime.now().toIso8601String(),
      });

      _activeSpotlight = spotlight;
      _paymentStatus = 'success';
      
      // Add to history
      _paymentHistory.insert(0, spotlight);
      
      return true;
    } catch (e) {
      _error = e.toString();
      _paymentStatus = 'failed';
      return false;
    } finally {
      _isProcessing = false;
      await Future.delayed(const Duration(seconds: 2)); // Show status briefly
      _paymentStatus = 'idle';
      notifyListeners();
    }
  }

  /// Listen to real-time payment status from Socket.io
  void _listenToPaymentStatus() {
    _paymentStatusListener?.cancel();
    _paymentStatusListener = _socketService.messages.listen((message) {
      if (message['type'] == 'payment_status') {
        final status = message['status'] as String?;
        if (status != null) {
          _paymentStatus = status;
          notifyListeners();
        }
      }
    });
  }

  /// Get the price for a tier
  String _getTierPrice(SpotlightTier tier) {
    switch (tier) {
      case SpotlightTier.bronze:
        return '4.99';
      case SpotlightTier.silver:
        return '9.99';
      case SpotlightTier.gold:
        return '19.99';
      case SpotlightTier.platinum:
        return '49.99';
    }
  }

  /// Cancel an active spotlight (if allowed)
  Future<bool> cancelActiveSpotlight(String spotlightId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Call backend to cancel
      // await _spotlightService.cancelSpotlight(spotlightId);
      
      _activeSpotlight = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get spotlight statistics
  Future<Map<String, dynamic>> getSpotlightStats(String userId) async {
    try {
      return await _spotlightService.getSpotlightStats(userId);
    } catch (e) {
      _error = e.toString();
      return {};
    }
  }

  @override
  void dispose() {
    _paymentStatusListener?.cancel();
    super.dispose();
  }
}

