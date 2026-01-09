import 'package:flutter/material.dart';
import '../models/route_path.dart';

class MeengleRouteInformationParser extends RouteInformationParser<RoutePath> {
  @override
  Future<RoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = routeInformation.uri;
    
    // Handle login
    if (uri.pathSegments.isEmpty || uri.path == '/login') {
      return LoginRoutePath();
    }

    // Handle signup
    if (uri.path == '/signup') {
      return SignupRoutePath();
    }

    // Handle chat
    if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'chat') {
      return ChatRoutePath(uri.pathSegments[1]);
    }

    // Handle profile
    if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'profile') {
      return ProfileRoutePath(uri.pathSegments[1]);
    }

    // Handle matches
    if (uri.path == '/matches') {
      return MatchesRoutePath();
    }

    // Handle settings
    if (uri.path == '/settings') {
      return SettingsRoutePath();
    }

    // Handle payment
    if (uri.path == '/subscribe') {
      return PaymentRoutePath();
    }

    // Handle unknown routes
    return UnknownRoutePath();
  }

  @override
  RouteInformation? restoreRouteInformation(RoutePath configuration) {
    if (configuration is LoginRoutePath) {
      return RouteInformation(uri: Uri.parse('/login'));
    }
    if (configuration is SignupRoutePath) {
      return RouteInformation(uri: Uri.parse('/signup'));
    }
    if (configuration is ChatRoutePath) {
      return RouteInformation(uri: Uri.parse('/chat/${configuration.chatId}'));
    }
    if (configuration is ProfileRoutePath) {
      return RouteInformation(uri: Uri.parse('/profile/${configuration.userId}'));
    }
    if (configuration is MatchesRoutePath) {
      return RouteInformation(uri: Uri.parse('/matches'));
    }
    if (configuration is SettingsRoutePath) {
      return RouteInformation(uri: Uri.parse('/settings'));
    }
    if (configuration is PaymentRoutePath) {
      return RouteInformation(uri: Uri.parse('/subscribe'));
    }
    return RouteInformation(uri: Uri.parse('/404'));
  }
}