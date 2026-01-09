import 'package:flutter_test/flutter_test.dart';
import 'package:meengle_flutter/models/meengle_checkin.dart';

void main() {
  group('MeengleCheckIn Model Tests', () {
    
    group('CheckIn Creation', () {
      
      test('should create CheckIn with all valid parameters', () {
        final now = DateTime.now();
        final expiresAt = now.add(const Duration(hours: 4));
        final checkIn = MeengleCheckIn(
          id: 'checkin-001',
          userId: 'user-123',
          username: 'Alex Johnson',
          photoUrl: 'https://example.com/alex.jpg',
          age: 28,
          vibe: 'Adventurous',
          latitude: 40.7128,
          longitude: -74.0060,
          createdAt: now,
          expiresAt: expiresAt,
          locationName: 'Central Park',
        );
        
        expect(checkIn.id, equals('checkin-001'));
        expect(checkIn.userId, equals('user-123'));
        expect(checkIn.username, equals('Alex Johnson'));
        expect(checkIn.photoUrl, equals('https://example.com/alex.jpg'));
        expect(checkIn.age, equals(28));
        expect(checkIn.vibe, equals('Adventurous'));
        expect(checkIn.latitude, equals(40.7128));
        expect(checkIn.longitude, equals(-74.0060));
        expect(checkIn.createdAt, equals(now));
        expect(checkIn.expiresAt, equals(expiresAt));
      });
      
      test('should handle empty or null optional fields', () {
        final now = DateTime.now();
        final checkIn = MeengleCheckIn(
          id: 'checkin-002',
          userId: 'user-124',
          username: 'Jane Doe',
          photoUrl: '',
          age: 25,
          vibe: 'Chill',
          latitude: 34.0522,
          longitude: -118.2437,
          createdAt: now,
          expiresAt: now.add(const Duration(hours: 4)),
          locationName: 'LA Location',
        );
        
        expect(checkIn.photoUrl, equals(''));
      });
    });
    
    group('Location Validation', () {
      
      test('should accept valid latitude values (-90 to 90)', () {
        final now = DateTime.now();
        final checkIns = [
          MeengleCheckIn(
            id: 'test-1',
            userId: 'user-1',
            username: 'User1',
            photoUrl: 'url',
            age: 25,
            vibe: 'Social',
            latitude: -90, // South Pole
            longitude: 0,
            createdAt: now,
            expiresAt: now.add(const Duration(hours: 4)),
            locationName: 'Pole Location 1',
          ),
          MeengleCheckIn(
            id: 'test-2',
            userId: 'user-2',
            username: 'User2',
            photoUrl: 'url',
            age: 25,
            vibe: 'Social',
            latitude: 0, // Equator
            longitude: 0,
            createdAt: now,
            expiresAt: now.add(const Duration(hours: 4)),
            locationName: 'Equator Location',
          ),
          MeengleCheckIn(
            id: 'test-3',
            userId: 'user-3',
            username: 'User3',
            photoUrl: 'url',
            age: 25,
            vibe: 'Social',
            latitude: 90, // North Pole
            longitude: 0,
            createdAt: now,
            expiresAt: now.add(const Duration(hours: 4)),
            locationName: 'Pole Location 2',
          ),
        ];
        
        for (var checkIn in checkIns) {
          expect(checkIn.latitude >= -90 && checkIn.latitude <= 90, isTrue);
        }
      });
      
      test('should accept valid longitude values (-180 to 180)', () {
        final now = DateTime.now();
        final checkIns = [
          MeengleCheckIn(
            id: 'test-1',
            userId: 'user-1',
            username: 'User1',
            photoUrl: 'url',
            age: 25,
            vibe: 'Social',
            latitude: 0,
            longitude: -180, // Date Line West
            createdAt: now,
            expiresAt: now.add(const Duration(hours: 4)),
            locationName: 'Date Line West',
          ),
          MeengleCheckIn(
            id: 'test-2',
            userId: 'user-2',
            username: 'User2',
            photoUrl: 'url',
            age: 25,
            vibe: 'Social',
            latitude: 0,
            longitude: 0, // Prime Meridian
            createdAt: now,
            expiresAt: now.add(const Duration(hours: 4)),
            locationName: 'Prime Meridian',
          ),
          MeengleCheckIn(
            id: 'test-3',
            userId: 'user-3',
            username: 'User3',
            photoUrl: 'url',
            age: 25,
            vibe: 'Social',
            latitude: 0,
            longitude: 180, // Date Line East
            createdAt: now,
            expiresAt: now.add(const Duration(hours: 4)),
            locationName: 'Date Line East',
          ),
        ];
        
        for (var checkIn in checkIns) {
          expect(checkIn.longitude >= -180 && checkIn.longitude <= 180, isTrue);
        }
      });
      
      test('should handle real city coordinates', () {
        final now = DateTime.now();
        // New York
        final nyCheckIn = MeengleCheckIn(
          id: 'ny-1',
          userId: 'user-ny',
          username: 'New Yorker',
          photoUrl: 'url',
          age: 25,
          vibe: 'Urban',
          latitude: 40.7128,
          longitude: -74.0060,
          createdAt: now,
          expiresAt: now.add(const Duration(hours: 4)),
          locationName: 'New York City',
        );
        
        expect(nyCheckIn.latitude, closeTo(40.7128, 0.0001));
        expect(nyCheckIn.longitude, closeTo(-74.0060, 0.0001));
      });
    });
    
    group('Duration Handling', () {
      
      test('should track duration correctly', () {
        final now = DateTime.now();
        final expiresAt = now.add(const Duration(hours: 2));
        final checkIn = MeengleCheckIn(
          id: 'duration-test',
          userId: 'user-1',
          username: 'User',
          photoUrl: 'url',
          age: 25,
          vibe: 'Chill',
          latitude: 40.0,
          longitude: -74.0,
          createdAt: now,
          expiresAt: expiresAt,
          locationName: 'Test Location',
        );
        
        expect(checkIn.expiresAt.difference(checkIn.createdAt).inHours, equals(2));
      });
      
      test('should handle zero duration', () {
        final now = DateTime.now();
        final checkIn = MeengleCheckIn(
          id: 'zero-duration',
          userId: 'user-1',
          username: 'User',
          photoUrl: 'url',
          age: 25,
          vibe: 'Quick',
          latitude: 40.0,
          longitude: -74.0,
          createdAt: now,
          expiresAt: now,
          locationName: 'Instant Location',
        );
        
        expect(checkIn.expiresAt.difference(checkIn.createdAt).inMinutes, equals(0));
      });
    });
    
    group('CheckInStreak Model', () {
      
      test('should create streak with correct values', () {
        final lastCheck = DateTime.now();
        final streak = CheckInStreak(
          userId: 'user-123',
          currentStreak: 7,
          longestStreak: 15,
          totalCheckIns: 42,
          lastCheckInDate: lastCheck,
          uniqueLocations: 12,
        );
        
        expect(streak.currentStreak, equals(7));
        expect(streak.longestStreak, equals(15));
        expect(streak.totalCheckIns, equals(42));
        expect(streak.lastCheckInDate, equals(lastCheck));
      });
      
      test('should track zero streak correctly', () {
        final streak = CheckInStreak(
          userId: 'user-124',
          currentStreak: 0,
          longestStreak: 5,
          totalCheckIns: 1,
          lastCheckInDate: DateTime(2025, 1, 1),
          uniqueLocations: 1,
        );
        
        expect(streak.currentStreak, equals(0));
        expect(streak.longestStreak, greaterThan(streak.currentStreak));
      });
      
      test('should maintain streak consistency', () {
        final streak = CheckInStreak(
          userId: 'user-125',
          currentStreak: 10,
          longestStreak: 10,
          totalCheckIns: 10,
          lastCheckInDate: DateTime.now(),
          uniqueLocations: 5,
        );
        
        // Current streak should never exceed longest streak
        expect(streak.currentStreak, lessThanOrEqualTo(streak.longestStreak));
        
        // Total check-ins should be at least as many as longest streak
        expect(streak.totalCheckIns, greaterThanOrEqualTo(streak.longestStreak));
      });
    });
    
    group('Badge Model', () {
      
      test('should track check-in badge types', () {
        final badges = <CheckInBadgeType>[
          CheckInBadgeType.streak3,
          CheckInBadgeType.streak7,
          CheckInBadgeType.streak30,
          CheckInBadgeType.socialButterfly,
          CheckInBadgeType.vibeVendor,
          CheckInBadgeType.locationExplorer,
          CheckInBadgeType.eventParticipant,
          CheckInBadgeType.compatibilityMatches,
        ];
        
        expect(badges.length, equals(8));
        expect(badges[0].title, contains('3'));
      });
      
      test('should have badge descriptions', () {
        expect(CheckInBadgeType.streak7.description, isNotEmpty);
        expect(CheckInBadgeType.streak7.title, isNotEmpty);
      });
    });
    
    group('FlashEvent Model', () {
      
      test('should create flash event with correct data', () {
        final startTime = DateTime.now();
        final endTime = startTime.add(const Duration(hours: 2));
        
        final event = FlashEvent(
          id: 'event-001',
          title: 'Pizza Night',
          description: 'Join us for pizza!',
          locationName: 'Central Park',
          startsAt: startTime,
          expiresAt: endTime,
          latitude: 40.7829,
          longitude: -73.9654,
          emoji: '🍕',
          topVibes: ['Foodie', 'Social'],
          participantCount: 42,
        );
        
        expect(event.id, equals('event-001'));
        expect(event.title, equals('Pizza Night'));
        expect(event.participantCount, equals(42));
        expect(event.topVibes.length, equals(2));
      });
      
      test('should determine if event is active', () {
        final now = DateTime.now();
        final activeEvent = FlashEvent(
          id: 'active',
          title: 'Active Event',
          description: 'desc',
          locationName: 'loc',
          startsAt: now.subtract(const Duration(hours: 1)),
          expiresAt: now.add(const Duration(hours: 1)),
          latitude: 40.0,
          longitude: -74.0,
          emoji: '🎉',
          topVibes: [],
          participantCount: 10,
        );
        
        expect(now.isAfter(activeEvent.startsAt), isTrue);
        expect(now.isBefore(activeEvent.expiresAt), isTrue);
        expect(activeEvent.isActive, isTrue);
      });
      
      test('should calculate time remaining', () {
        final now = DateTime.now();
        final futureEvent = FlashEvent(
          id: 'future',
          title: 'Future Event',
          description: 'desc',
          locationName: 'loc',
          startsAt: now.add(const Duration(hours: 1)),
          expiresAt: now.add(const Duration(hours: 3)),
          latitude: 40.0,
          longitude: -74.0,
          emoji: '🎉',
        );
        
        expect(futureEvent.isActive, isFalse);
      });
    });
  });
}
