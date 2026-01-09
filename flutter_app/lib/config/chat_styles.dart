import 'package:flutter/material.dart';

class ChatStyles {
  static const double narrowScreenWidth = 600;
  static const double wideScreenWidth = 1200;
  static const double sidePanelWidth = 320;
  
  static const double maxContentWidth = 800;
  static const double maxMessageWidth = 600;
  
  static double getMessageWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > wideScreenWidth) {
      return maxMessageWidth;
    } else if (width > narrowScreenWidth) {
      return width * 0.6;
    }
    return width * 0.75;
  }
  
  static EdgeInsets getMessagePadding(bool isWideScreen) {
    return EdgeInsets.symmetric(
      horizontal: isWideScreen ? 24.0 : 16.0,
      vertical: isWideScreen ? 16.0 : 12.0,
    );
  }
  
  static TextStyle getMessageTextStyle(bool isWideScreen) {
    return TextStyle(
      fontSize: isWideScreen ? 16.0 : 14.0,
      height: 1.4,
    );
  }
  
  static double getAvatarSize(bool isWideScreen) {
    return isWideScreen ? 48.0 : 40.0;
  }
  
  static double getStatusDotSize(bool isWideScreen) {
    return isWideScreen ? 8.0 : 6.0;
  }
  
  static EdgeInsets getInputPadding(bool isWideScreen) {
    return EdgeInsets.symmetric(
      horizontal: isWideScreen ? 24.0 : 16.0,
      vertical: isWideScreen ? 16.0 : 12.0,
    ).copyWith(bottom: isWideScreen ? 24.0 : 16.0);
  }
  
  static TextStyle getInputTextStyle(bool isWideScreen) {
    return TextStyle(
      fontSize: isWideScreen ? 16.0 : 14.0,
    );
  }
  
  static BorderRadius getMessageBorderRadius(bool isWideScreen) {
    return BorderRadius.circular(isWideScreen ? 16.0 : 12.0);
  }
  
  static double getTypingIndicatorSize(bool isWideScreen) {
    return isWideScreen ? 10.0 : 8.0;
  }
}