import 'package:flutter/material.dart';
import 'dart:async';

/// Internationalization service for multi-language support
class I18nService {
  static final I18nService _instance = I18nService._internal();
  
  late Locale _currentLocale;
  late Map<String, Map<String, String>> _translations;
  final _localeChangeController = StreamController<Locale>.broadcast();

  factory I18nService() {
    return _instance;
  }

  I18nService._internal();

  /// Initialize localization
  Future<void> initialize(Locale initialLocale) async {
    _currentLocale = initialLocale;
    _translations = await _loadTranslations();
  }

  /// Load translations
  Future<Map<String, Map<String, String>>> _loadTranslations() async {
    // In production, load from backend or JSON files
    return {
      'en': _englishTranslations(),
      'es': _spanishTranslations(),
      'fr': _frenchTranslations(),
      'de': _germanTranslations(),
      'pt': _portugueseTranslations(),
      'ja': _japaneseTranslations(),
      'zh': _chineseTranslations(),
    };
  }

  /// Get translated string
  String translate(String key) {
    return _translations[_currentLocale.languageCode]?[key] ?? key;
  }

  /// Change locale
  Future<void> changeLocale(Locale newLocale) async {
    _currentLocale = newLocale;
    _localeChangeController.add(newLocale);
    // Save locale preference
  }

  /// Get current locale
  Locale get currentLocale => _currentLocale;

  /// Get locale change stream
  Stream<Locale> get localeChangeStream => _localeChangeController.stream;

  /// Get supported locales
  List<Locale> getSupportedLocales() {
    return [
      const Locale('en'),
      const Locale('es'),
      const Locale('fr'),
      const Locale('de'),
      const Locale('pt'),
      const Locale('ja'),
      const Locale('zh'),
    ];
  }

  /// Format date with localization
  String formatDate(DateTime date, String format) {
    // Use intl package for proper date formatting
    return date.toString();
  }

  /// Format currency with localization
  String formatCurrency(double amount, String currencyCode) {
    // Use intl package for proper currency formatting
    return '\$$amount';
  }

  // Translation maps
  Map<String, String> _englishTranslations() {
    return {
      'app_name': 'Meengle',
      'hello': 'Hello',
      'welcome': 'Welcome',
      'login': 'Login',
      'signup': 'Sign Up',
      'profile': 'Profile',
      'messages': 'Messages',
      'discover': 'Discover',
      'like_button': 'Like',
      'pass_button': 'Pass',
      'chat_now': 'Chat Now',
      'extend_match': 'Extend Match',
      'moments': 'Moments',
      'stories': 'Stories',
      'notes': 'Notes',
      'circles': 'Circles',
      'dates': 'Date Ideas',
      'spotlight': 'Spotlight',
      'roam': 'Travel Mode',
      'verification': 'Verification',
      'settings': 'Settings',
      'logout': 'Logout',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',
    };
  }

  Map<String, String> _spanishTranslations() {
    return {
      'app_name': 'Meengle',
      'hello': 'Hola',
      'welcome': 'Bienvenido',
      'login': 'Iniciar sesión',
      'signup': 'Registrarse',
      'profile': 'Perfil',
      'messages': 'Mensajes',
      'discover': 'Descubrir',
      'like_button': 'Me gusta',
      'pass_button': 'Pasar',
      'chat_now': 'Chatear ahora',
      'extend_match': 'Extender coincidencia',
      'moments': 'Momentos',
      'stories': 'Historias',
      'notes': 'Notas',
      'circles': 'Círculos',
      'dates': 'Ideas de citas',
      'spotlight': 'Destacado',
      'roam': 'Modo viaje',
      'verification': 'Verificación',
      'settings': 'Configuración',
      'logout': 'Cerrar sesión',
      'error': 'Error',
      'success': 'Éxito',
      'loading': 'Cargando...',
    };
  }

  Map<String, String> _frenchTranslations() {
    return {
      'app_name': 'Meengle',
      'hello': 'Bonjour',
      'welcome': 'Bienvenue',
      'login': 'Connexion',
      'signup': 'Inscription',
      'profile': 'Profil',
      'messages': 'Messages',
      'discover': 'Découvrir',
      'like_button': 'J\'aime',
      'pass_button': 'Passer',
      'chat_now': 'Discuter maintenant',
      'extend_match': 'Prolonger la correspondance',
      'moments': 'Moments',
      'stories': 'Histoires',
      'notes': 'Notes',
      'circles': 'Cercles',
      'dates': 'Idées de rendez-vous',
      'spotlight': 'Projecteur',
      'roam': 'Mode voyage',
      'verification': 'Vérification',
      'settings': 'Paramètres',
      'logout': 'Déconnexion',
      'error': 'Erreur',
      'success': 'Succès',
      'loading': 'Chargement...',
    };
  }

  Map<String, String> _germanTranslations() {
    return {
      'app_name': 'Meengle',
      'hello': 'Hallo',
      'welcome': 'Willkommen',
      'login': 'Anmelden',
      'signup': 'Registrieren',
      'profile': 'Profil',
      'messages': 'Nachrichten',
      'discover': 'Entdecken',
      'like_button': 'Mag ich',
      'pass_button': 'Weiter',
      'chat_now': 'Jetzt chatten',
      'extend_match': 'Treffer verlängern',
      'moments': 'Momente',
      'stories': 'Geschichten',
      'notes': 'Notizen',
      'circles': 'Kreise',
      'dates': 'Datierungsideen',
      'spotlight': 'Spotlight',
      'roam': 'Reisemodus',
      'verification': 'Verifikation',
      'settings': 'Einstellungen',
      'logout': 'Abmelden',
      'error': 'Fehler',
      'success': 'Erfolg',
      'loading': 'Wird geladen...',
    };
  }

  Map<String, String> _portugueseTranslations() {
    return {
      'app_name': 'Meengle',
      'hello': 'Olá',
      'welcome': 'Bem-vindo',
      'login': 'Entrar',
      'signup': 'Inscrever-se',
      'profile': 'Perfil',
      'messages': 'Mensagens',
      'discover': 'Descobrir',
      'like_button': 'Gosto',
      'pass_button': 'Passar',
      'chat_now': 'Conversar agora',
      'extend_match': 'Estender correspondência',
      'moments': 'Momentos',
      'stories': 'Histórias',
      'notes': 'Notas',
      'circles': 'Círculos',
      'dates': 'Ideias de encontros',
      'spotlight': 'Destaque',
      'roam': 'Modo de viagem',
      'verification': 'Verificação',
      'settings': 'Configurações',
      'logout': 'Sair',
      'error': 'Erro',
      'success': 'Sucesso',
      'loading': 'Carregando...',
    };
  }

  Map<String, String> _japaneseTranslations() {
    return {
      'app_name': 'Meengle',
      'hello': '?????',
      'welcome': '????',
      'login': '????',
      'signup': '??????',
      'profile': '??????',
      'messages': '?????',
      'discover': '??',
      'like_button': '??',
      'pass_button': '??',
      'chat_now': '???????',
      'extend_match': '??????',
      'moments': '?????',
      'stories': '?????',
      'notes': '???',
      'circles': '????',
      'dates': '????????',
      'spotlight': '???????',
      'roam': '???????',
      'verification': '??',
      'settings': '??',
      'logout': '?????',
      'error': '???',
      'success': '??',
      'loading': '?????...',
    };
  }

  Map<String, String> _chineseTranslations() {
    return {
      'app_name': 'Meengle',
      'hello': '??',
      'welcome': '??',
      'login': '??',
      'signup': '??',
      'profile': '????',
      'messages': '??',
      'discover': '??',
      'like_button': '??',
      'pass_button': '??',
      'chat_now': '????',
      'extend_match': '????',
      'moments': '??',
      'stories': '??',
      'notes': '??',
      'circles': '??',
      'dates': '????',
      'spotlight': '???',
      'roam': '????',
      'verification': '??',
      'settings': '??',
      'logout': '??',
      'error': '??',
      'success': '??',
      'loading': '???...',
    };
  }

  /// Dispose
  void dispose() {
    _localeChangeController.close();
  }
}
