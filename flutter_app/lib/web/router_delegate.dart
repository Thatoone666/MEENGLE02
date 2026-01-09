import 'package:flutter/material.dart';
import '../models/route_path.dart';
import '../screens/login.dart';
import '../screens/signup.dart';
import '../screens/chat.dart';
import '../screens/matches_list.dart';
import '../screens/payments.dart';

class MeengleRouterDelegate extends RouterDelegate<RoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  MeengleRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  String? _selectedChatId;
  String? _selectedUserId;
  String? get selectedChatId => _selectedChatId;
  String? get selectedUserId => _selectedUserId;

  bool _isLoggedIn = false;
  bool _showLogin = true;
  bool _showSignup = false;
  bool _showMatches = false;
  bool _showPayment = false;

  @override
  RoutePath get currentConfiguration {
    if (!_isLoggedIn) {
      return _showSignup ? SignupRoutePath() : LoginRoutePath();
    }

    if (_selectedChatId != null) {
      return ChatRoutePath(_selectedChatId!);
    }

    if (_selectedUserId != null) {
      return ProfileRoutePath(_selectedUserId!);
    }

    if (_showMatches) {
      return MatchesRoutePath();
    }

    if (_showPayment) {
      return PaymentRoutePath();
    }

    return UnknownRoutePath();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        if (!_isLoggedIn) ...[
          if (_showLogin)
            MaterialPage(
              key: const ValueKey('LoginPage'),
              child: const LoginScreen(),
            ),
          if (_showSignup)
            MaterialPage(
              key: const ValueKey('SignupPage'),
              child: const SignupScreen(),
            ),
        ] else ...[
          if (_selectedChatId != null)
            MaterialPage(
              key: ValueKey('ChatPage_$_selectedChatId'),
              child: ChatScreen(userId: _selectedChatId),
            ),
          if (_showMatches)
            MaterialPage(
              key: const ValueKey('MatchesPage'),
              child: MatchesListScreen(),
            ),
          if (_showPayment)
            MaterialPage(
              key: const ValueKey('PaymentPage'),
              child: PaymentsScreen(),
            ),
        ],
      ],
      onDidRemovePage: (page) {
        // Handle back navigation
        _selectedChatId = null;
        _selectedUserId = null;
        _showMatches = false;
        _showPayment = false;
        notifyListeners();
      },
    );
  }

  @override
  Future<void> setNewRoutePath(RoutePath configuration) async {
    if (configuration is LoginRoutePath) {
      _isLoggedIn = false;
      _showLogin = true;
      _showSignup = false;
    } else if (configuration is SignupRoutePath) {
      _isLoggedIn = false;
      _showLogin = false;
      _showSignup = true;
    } else if (configuration is ChatRoutePath) {
      _selectedChatId = configuration.chatId;
      _selectedUserId = null;
      _showMatches = false;
      _showPayment = false;
    } else if (configuration is ProfileRoutePath) {
      _selectedUserId = configuration.userId;
      _selectedChatId = null;
      _showMatches = false;
      _showPayment = false;
    } else if (configuration is MatchesRoutePath) {
      _showMatches = true;
      _selectedChatId = null;
      _selectedUserId = null;
      _showPayment = false;
    } else if (configuration is PaymentRoutePath) {
      _showPayment = true;
      _selectedChatId = null;
      _selectedUserId = null;
      _showMatches = false;
    }
  }

  void handleLogin() {
    _isLoggedIn = true;
    _showLogin = false;
    _showSignup = false;
    notifyListeners();
  }

  void handleLogout() {
    _isLoggedIn = false;
    _showLogin = true;
    _showSignup = false;
    _selectedChatId = null;
    _selectedUserId = null;
    _showMatches = false;
    _showPayment = false;
    notifyListeners();
  }
}