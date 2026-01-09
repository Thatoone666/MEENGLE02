import 'package:equatable/equatable.dart';

/// Categories of date ideas
enum DateCategory {
  adventure,
  casual,
  cultural,
  food,
  outdoor,
  romantic,
  creative,
  sports,
}

extension DateCategoryExtension on DateCategory {
  String get label {
    switch (this) {
      case DateCategory.adventure:
        return 'Adventure';
      case DateCategory.casual:
        return 'Casual';
      case DateCategory.cultural:
        return 'Cultural';
      case DateCategory.food:
        return 'Food';
      case DateCategory.outdoor:
        return 'Outdoor';
      case DateCategory.romantic:
        return 'Romantic';
      case DateCategory.creative:
        return 'Creative';
      case DateCategory.sports:
        return 'Sports';
    }
  }

  String get emoji {
    switch (this) {
      case DateCategory.adventure:
        return '🎒';
      case DateCategory.casual:
        return '☕';
      case DateCategory.cultural:
        return '🎭';
      case DateCategory.food:
        return '🍽️';
      case DateCategory.outdoor:
        return '⛰️';
      case DateCategory.romantic:
        return '🌹';
      case DateCategory.creative:
        return '🎨';
      case DateCategory.sports:
        return '⚽';
    }
  }
}

/// Represents a suggested date idea with AI-powered matching
class MeengleDate extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateCategory category;
  final String location; // Address or location name
  final double? latitude;
  final double? longitude;
  final int estimatedDuration; // In minutes
  final int estimatedCost; // 1-4 ($ signs)
  final String? websiteUrl;
  final String? phoneNumber;
  final List<String> tags; // Keywords
  final int popularity; // 1-5 stars
  final String imageUrl;
  final bool isAIRecommended; // Whether suggested by AI
  final String? reason; // Why AI recommended this

  const MeengleDate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.latitude,
    this.longitude,
    required this.estimatedDuration,
    required this.estimatedCost,
    this.websiteUrl,
    this.phoneNumber,
    required this.tags,
    required this.popularity,
    required this.imageUrl,
    this.isAIRecommended = false,
    this.reason,
  });

  /// Get cost as string (e.g., "$" or "$$$$")
  String get costString => '\$' * estimatedCost;

  /// Get duration as formatted string (e.g., "2h 30m")
  String get durationFormatted {
    final hours = estimatedDuration ~/ 60;
    final minutes = estimatedDuration % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  MeengleDate copyWith({
    String? id,
    String? title,
    String? description,
    DateCategory? category,
    String? location,
    double? latitude,
    double? longitude,
    int? estimatedDuration,
    int? estimatedCost,
    String? websiteUrl,
    String? phoneNumber,
    List<String>? tags,
    int? popularity,
    String? imageUrl,
    bool? isAIRecommended,
    String? reason,
  }) {
    return MeengleDate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      tags: tags ?? this.tags,
      popularity: popularity ?? this.popularity,
      imageUrl: imageUrl ?? this.imageUrl,
      isAIRecommended: isAIRecommended ?? this.isAIRecommended,
      reason: reason ?? this.reason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'estimatedDuration': estimatedDuration,
      'estimatedCost': estimatedCost,
      'websiteUrl': websiteUrl,
      'phoneNumber': phoneNumber,
      'tags': tags,
      'popularity': popularity,
      'imageUrl': imageUrl,
      'isAIRecommended': isAIRecommended,
      'reason': reason,
    };
  }

  factory MeengleDate.fromJson(Map<String, dynamic> json) {
    return MeengleDate(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: DateCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      location: json['location'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      estimatedDuration: json['estimatedDuration'] as int,
      estimatedCost: json['estimatedCost'] as int,
      websiteUrl: json['websiteUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      tags: List<String>.from(json['tags'] as List),
      popularity: json['popularity'] as int,
      imageUrl: json['imageUrl'] as String,
      isAIRecommended: json['isAIRecommended'] as bool? ?? false,
      reason: json['reason'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        location,
        latitude,
        longitude,
        estimatedDuration,
        estimatedCost,
        websiteUrl,
        phoneNumber,
        tags,
        popularity,
        imageUrl,
        isAIRecommended,
        reason,
      ];
}
