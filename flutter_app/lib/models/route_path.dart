abstract class RoutePath {}

class LoginRoutePath extends RoutePath {}

class SignupRoutePath extends RoutePath {}

class ChatRoutePath extends RoutePath {
  final String chatId;
  ChatRoutePath(this.chatId);
}

class ProfileRoutePath extends RoutePath {
  final String userId;
  ProfileRoutePath(this.userId);
}

class MatchesRoutePath extends RoutePath {}

class SettingsRoutePath extends RoutePath {}

class PaymentRoutePath extends RoutePath {}

class UnknownRoutePath extends RoutePath {}