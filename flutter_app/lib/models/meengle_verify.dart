import 'package:equatable/equatable.dart';

/// Types of verification available in Meengle
enum VerificationType {
  phone,
  email,
  face,
  idDocument,
  video,
  social,
  background,
}

extension VerificationTypeExtension on VerificationType {
  String get label {
    switch (this) {
      case VerificationType.phone:
        return 'Phone';
      case VerificationType.email:
        return 'Email';
      case VerificationType.face:
        return 'Face ID';
      case VerificationType.idDocument:
        return 'ID Document';
      case VerificationType.video:
        return 'Video Intro';
      case VerificationType.social:
        return 'Social Proof';
      case VerificationType.background:
        return 'Background Check';
    }
  }

  String get emoji {
    switch (this) {
      case VerificationType.phone:
        return '📱';
      case VerificationType.email:
        return '📧';
      case VerificationType.face:
        return '😊';
      case VerificationType.idDocument:
        return '📄';
      case VerificationType.video:
        return '🎥';
      case VerificationType.social:
        return '🔗';
      case VerificationType.background:
        return '✅';
    }
  }

  int get points {
    switch (this) {
      case VerificationType.phone:
        return 10;
      case VerificationType.email:
        return 10;
      case VerificationType.face:
        return 25;
      case VerificationType.idDocument:
        return 30;
      case VerificationType.video:
        return 20;
      case VerificationType.social:
        return 15;
      case VerificationType.background:
        return 50;
    }
  }
}

enum VerificationStatus {
  pending,
  verified,
  rejected,
  expired,
}

extension VerificationStatusExtension on VerificationStatus {
  String get label {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.expired:
        return 'Expired';
    }
  }
}

/// Represents a single verification check
class UserVerification extends Equatable {
  final String id;
  final String userId;
  final VerificationType type;
  final VerificationStatus status;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final DateTime? expiresAt;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const UserVerification({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.verifiedAt,
    this.expiresAt,
    this.notes,
    this.metadata,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isActive =>
      status == VerificationStatus.verified && !isExpired;

  UserVerification copyWith({
    String? id,
    String? userId,
    VerificationType? type,
    VerificationStatus? status,
    DateTime? createdAt,
    DateTime? verifiedAt,
    DateTime? expiresAt,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return UserVerification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
    };
  }

  factory UserVerification.fromJson(Map<String, dynamic> json) {
    return UserVerification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: VerificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      status: VerificationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        status,
        createdAt,
        verifiedAt,
        expiresAt,
        notes,
        metadata,
      ];
}

/// User verification badge/status overview
class UserVerificationBadge extends Equatable {
  final String userId;
  final int trustScore; // 0-100
  final List<UserVerification> verifications;
  final DateTime lastUpdated;

  const UserVerificationBadge({
    required this.userId,
    required this.trustScore,
    required this.verifications,
    required this.lastUpdated,
  });

  /// Get verified verification types
  List<VerificationType> get verifiedTypes {
    return verifications
        .where((v) => v.isActive)
        .map((v) => v.type)
        .toList();
  }

  /// Get pending verification types
  List<VerificationType> get pendingTypes {
    return verifications
        .where((v) => v.status == VerificationStatus.pending)
        .map((v) => v.type)
        .toList();
  }

  /// Calculate trust score based on verifications
  static int calculateTrustScore(List<UserVerification> verifications) {
    int score = 0;
    for (final v in verifications) {
      if (v.isActive) {
        score += v.type.points;
      }
    }
    return (score / 5).clamp(0, 100).toInt(); // Max ~100 points
  }

  UserVerificationBadge copyWith({
    String? userId,
    int? trustScore,
    List<UserVerification>? verifications,
    DateTime? lastUpdated,
  }) {
    return UserVerificationBadge(
      userId: userId ?? this.userId,
      trustScore: trustScore ?? this.trustScore,
      verifications: verifications ?? this.verifications,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'trustScore': trustScore,
      'verifications': verifications.map((v) => v.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UserVerificationBadge.fromJson(Map<String, dynamic> json) {
    final verifications = (json['verifications'] as List)
        .map((v) => UserVerification.fromJson(v as Map<String, dynamic>))
        .toList();
    return UserVerificationBadge(
      userId: json['userId'] as String,
      trustScore: json['trustScore'] as int,
      verifications: verifications,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  @override
  List<Object?> get props => [userId, trustScore, verifications, lastUpdated];
}
