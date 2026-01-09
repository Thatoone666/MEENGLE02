import 'package:flutter/material.dart';

enum SafetyFeatureType {
  verification,
  blocking,
  reporting,
  safetytips,
  emergency,
  privacycontrol,
  videoverifcation,
  background,
  locationsharing,
  facialrecognition,
}

class SafetyFeature {
  final SafetyFeatureType type;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final String? actionLabel;
  final VoidCallback? onTap;
  final bool isActive;
  final String? status;

  SafetyFeature({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    this.actionLabel,
    this.onTap,
    this.isActive = false,
    this.status,
  });
}

class BlockedUser {
  final String id;
  final String name;
  final String profileImage;
  final DateTime blockedAt;
  final String? reason;

  BlockedUser({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.blockedAt,
    this.reason,
  });
}

class SafetyTip {
  final String id;
  final String title;
  final String content;
  final String category;
  final IconData icon;
  final DateTime createdAt;

  SafetyTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.icon,
    required this.createdAt,
  });
}

class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final bool isVerified;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.isVerified,
  });
}

class LocationShareSession {
  final String id;
  final String contactName;
  final String contactId;
  final DateTime startedAt;
  final DateTime? expiresAt;
  final bool isActive;

  LocationShareSession({
    required this.id,
    required this.contactName,
    required this.contactId,
    required this.startedAt,
    this.expiresAt,
    required this.isActive,
  });
}

class SafetyPreferences {
  final bool allowVideoVerification;
  final bool requireVideoVerification;
  final bool enableLocationSharing;
  final bool shareLocationWithEmergencyContacts;
  final bool enableBackgroundCheck;
  final bool enableFacialRecognition;
  final bool blockScreenshots;
  final bool disableScreenshare;
  final List<String> blockedUsers;
  final List<EmergencyContact> emergencyContacts;

  SafetyPreferences({
    this.allowVideoVerification = true,
    this.requireVideoVerification = false,
    this.enableLocationSharing = false,
    this.shareLocationWithEmergencyContacts = false,
    this.enableBackgroundCheck = true,
    this.enableFacialRecognition = true,
    this.blockScreenshots = true,
    this.disableScreenshare = true,
    this.blockedUsers = const [],
    this.emergencyContacts = const [],
  });
}
