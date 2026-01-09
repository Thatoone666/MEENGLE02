import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility service for screen readers and voice control
class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  
  late bool _isScreenReaderEnabled;
  late bool _isHighContrastEnabled;
  late bool _isBoldTextEnabled;
  late double _textScaleFactor;

  factory AccessibilityService() {
    return _instance;
  }

  AccessibilityService._internal();

  /// Initialize accessibility
  Future<void> initialize(BuildContext context) async {
    // Detect accessibility settings
    _isScreenReaderEnabled = MediaQuery.of(context).highContrast;
    _isHighContrastEnabled = MediaQuery.of(context).highContrast;
    _textScaleFactor = MediaQuery.of(context).textScaleFactor;
    _isBoldTextEnabled = MediaQuery.of(context).boldText ?? false;
  }

  /// Get semantic labels
  String getSemanticLabel(String key) {
    const labels = {
      'like_button': 'Like this person',
      'pass_button': 'Pass on this person',
      'chat_button': 'Start a conversation',
      'story_card': 'Story from user',
      'match_card': 'Potential match',
      'profile_photo': 'Profile photo',
      'bio_text': 'User biography',
      'verify_button': 'Verify identity',
      'extend_match': 'Extend this match by 6 hours',
      'timer_badge': 'Time remaining for this match',
    };
    return labels[key] ?? key;
  }

  /// Build accessible text
  Widget buildAccessibleText(
    String text, {
    required TextStyle style,
    required String semanticLabel,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Semantics(
      label: semanticLabel,
      enabled: true,
      onTap: () {},
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        semanticsLabel: semanticLabel,
      ),
    );
  }

  /// Build accessible button
  Widget buildAccessibleButton({
    required VoidCallback onPressed,
    required Widget child,
    required String semanticLabel,
    String? hint,
  }) {
    return Semantics(
      button: true,
      enabled: true,
      onTap: onPressed,
      label: semanticLabel,
      hint: hint,
      child: GestureDetector(
        onTap: onPressed,
        child: Semantics(
          child: child,
        ),
      ),
    );
  }

  /// Build accessible image
  Widget buildAccessibleImage({
    required ImageProvider image,
    required String semanticLabel,
    double? width,
    double? height,
  }) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: Image(
        image: image,
        width: width,
        height: height,
        semanticLabel: semanticLabel,
      ),
    );
  }

  /// Build slider with accessibility
  Widget buildAccessibleSlider({
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required String semanticLabel,
  }) {
    return Semantics(
      slider: true,
      label: semanticLabel,
      onIncrease: value < max ? () => onChanged(value + 1) : null,
      onDecrease: value > min ? () => onChanged(value - 1) : null,
      child: Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
        semanticFormatterCallback: (value) =>
            '${value.toStringAsFixed(0)}',
      ),
    );
  }

  /// Check if accessibility features are enabled
  bool get isScreenReaderEnabled => _isScreenReaderEnabled;
  bool get isHighContrastEnabled => _isHighContrastEnabled;
  bool get isBoldTextEnabled => _isBoldTextEnabled;
  double get textScaleFactor => _textScaleFactor;

  /// Get accessible color
  Color getAccessibleColor(Color primaryColor, Color highContrastColor) {
    return _isHighContrastEnabled ? highContrastColor : primaryColor;
  }

  /// Announce for screen readers
  Future<void> announceForAccessibility(String message) async {
    SemanticsService.announce(
      message,
      textDirection: TextDirection.ltr,
    );
  }

  /// Build high contrast theme data
  ThemeData buildHighContrastTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.black,
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      buttonTheme: const ButtonThemeData(
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  /// Get font size for accessibility
  double getAccessibleFontSize(double baseSize) {
    return baseSize * _textScaleFactor;
  }

  /// Build voice control button
  Widget buildVoiceControlButton({
    required VoidCallback onPressed,
    required String semanticLabel,
  }) {
    return Semantics(
      enabled: true,
      onTap: onPressed,
      label: semanticLabel,
      hint: 'Double tap to activate',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: IconButton(
          icon: const Icon(Icons.mic),
          onPressed: onPressed,
          tooltip: semanticLabel,
        ),
      ),
    );
  }
}
