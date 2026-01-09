import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meengle_flutter/models/meengle_spotlight.dart';
import 'api.dart';

/// Service for managing Meengle Spotlight
class SpotlightService {
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiService.authKey);
  }

  /// Get user's current spotlight
  Future<MeengleSpotlight?> getUserActiveSpotlight(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/spotlight/active');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['active'] == true && data['spotlight'] != null) {
        return MeengleSpotlight.fromJson(data['spotlight']);
      }
    }
    return null;
  }

  /// Purchase spotlight
  Future<MeengleSpotlight> purchaseSpotlight({
    required String userId,
    required SpotlightTier tier,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/spotlight/purchase');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tier': tier.toString().split('.').last,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return MeengleSpotlight.fromJson(data['spotlight']);
    }
    throw Exception('Failed to purchase spotlight');
  }

  /// Get spotlight history
  Future<List<MeengleSpotlight>> getSpotlightHistory(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/spotlight/history');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final spotlights = (data['spotlights'] as List)
          .map((s) => MeengleSpotlight.fromJson(s))
          .toList();
      return spotlights;
    }
    return [];
  }

  /// Get spotlight statistics
  Future<Map<String, dynamic>> getSpotlightStats(String userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final url = Uri.parse('${ApiService.baseUrl}/spotlight/stats');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {
      'currentSpotlight': null,
      'totalPurchases': 0,
      'bestPerformer': null,
      'totalEngagement': 0,
    };
  }

  /// Activate spotlight boost
  Future<MeengleSpotlight> activateSpotlightBoost({
    required String userId,
    required SpotlightTier tier,
  }) async {
    return purchaseSpotlight(userId: userId, tier: tier);
  }

  /// Get spotlight tiers info
  Future<List<SpotlightTierInfo>> getSpotlightTiers() async {
    return [
      SpotlightTierInfo(
        tier: SpotlightTier.bronze,
        title: 'Bronze Boost',
        description: 'Get started with visibility',
        benefits: [
          '1x visibility for 1 hour',
          'See who views your profile',
        ],
        costInTokens: 0,
        highlighted: false,
      ),
      SpotlightTierInfo(
        tier: SpotlightTier.silver,
        title: 'Silver Shine',
        description: 'Double your visibility',
        benefits: [
          '2x more profile views',
          '6-hour visibility boost',
          'Highlighted in discovery',
          'Priority in matching',
        ],
        costInTokens: 999,
        highlighted: false,
      ),
      SpotlightTierInfo(
        tier: SpotlightTier.gold,
        title: 'Gold Star',
        description: 'Premium visibility',
        benefits: [
          '5x more profile views',
          '24-hour visibility boost',
          'Premium badge on profile',
          'Priority matching',
          'Advanced analytics',
        ],
        costInTokens: 1999,
        highlighted: true, // Popular choice
      ),
      SpotlightTierInfo(
        tier: SpotlightTier.platinum,
        title: 'Platinum Elite',
        description: 'Maximum visibility',
        benefits: [
          '10x more profile views',
          '72-hour visibility boost',
          'Platinum badge + exclusivity',
          'VIP matching queue',
          'Premium analytics',
          'Exclusive community access',
          'Concierge support',
        ],
        costInTokens: 4999,
        highlighted: false,
      ),
    ];
  }

  /// Track spotlight engagement
  Future<void> trackSpotlightEngagement({
    required String spotlightId,
    required String eventType, // 'view', 'like', 'super_like', 'message'
  }) async {
    final token = await _getToken();
    if (token == null) return;
    
    final url = Uri.parse('${ApiService.baseUrl}/spotlight/$spotlightId/$eventType');
    await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  /// Get recommendations for next tier
  Future<SpotlightTier?> getNextSpotlightRecommendation(
    String userId,
  ) async {
    final stats = await getSpotlightStats(userId);
    final current = stats['currentSpotlight'] as String?;
    
    // Simple logic: recommend next tier
    if (current == null) return SpotlightTier.bronze;
    if (current == 'bronze') return SpotlightTier.silver;
    if (current == 'silver') return SpotlightTier.gold;
    if (current == 'gold') return SpotlightTier.platinum;
    
    return null;
  }
}

/// Information about a spotlight tier
class SpotlightTierInfo {
  final SpotlightTier tier;
  final String title;
  final String description;
  final List<String> benefits;
  final int costInTokens;
  final bool highlighted;

  SpotlightTierInfo({
    required this.tier,
    required this.title,
    required this.description,
    required this.benefits,
    required this.costInTokens,
    required this.highlighted,
  });
}
