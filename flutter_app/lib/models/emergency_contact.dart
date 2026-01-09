/// Emergency contact and location sharing model
class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final bool isFavourite;
  final DateTime addedAt;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.isFavourite,
    required this.addedAt,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      isFavourite: json['isFavourite'] ?? false,
      addedAt: DateTime.parse(json['addedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'isFavourite': isFavourite,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}

/// Location data for emergency sharing
class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final String? address;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.address,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
    };
  }
}

/// Emergency service type
enum EmergencyServiceType {
  favourite('Favourite', Icons.heart),
  police('Police', Icons.security),
  hospital('Hospital', Icons.local_hospital),
  emergency('Emergency', Icons.emergency);

  final String label;
  final IconData icon;

  const EmergencyServiceType(this.label, this.icon);
}

import 'package:flutter/material.dart';

/// Emergency location share history
class EmergencyShareLog {
  final String id;
  final String userId;
  final String contactId;
  final EmergencyServiceType serviceType;
  final LocationData location;
  final DateTime sharedAt;
  final String? notes;
  final bool acknowledged;

  EmergencyShareLog({
    required this.id,
    required this.userId,
    required this.contactId,
    required this.serviceType,
    required this.location,
    required this.sharedAt,
    this.notes,
    required this.acknowledged,
  });

  factory EmergencyShareLog.fromJson(Map<String, dynamic> json) {
    return EmergencyShareLog(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      contactId: json['contactId'] ?? '',
      serviceType: EmergencyServiceType.values.firstWhere(
        (e) => e.name == json['serviceType'],
        orElse: () => EmergencyServiceType.emergency,
      ),
      location: LocationData.fromJson(json['location']),
      sharedAt: DateTime.parse(json['sharedAt'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'],
      acknowledged: json['acknowledged'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'contactId': contactId,
      'serviceType': serviceType.name,
      'location': location.toJson(),
      'sharedAt': sharedAt.toIso8601String(),
      'notes': notes,
      'acknowledged': acknowledged,
    };
  }
}
