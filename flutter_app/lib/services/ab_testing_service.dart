import 'dart:async';
import 'dart:math';

/// A/B Testing framework for feature experimentation
class ABTestingService {
  static final ABTestingService _instance = ABTestingService._internal();
  
  final Map<String, ABTest> _tests = {};
  final Map<String, String> _userVariants = {};
  
  factory ABTestingService() {
    return _instance;
  }

  ABTestingService._internal();

  /// Initialize A/B testing
  Future<void> initialize() async {
    // Load saved variants from local storage
    await _loadSavedVariants();
  }

  /// Create a new A/B test
  void createTest({
    required String testName,
    required List<String> variants,
    required double splitPercentage,
    bool isActive = true,
  }) {
    _tests[testName] = ABTest(
      name: testName,
      variants: variants,
      splitPercentage: splitPercentage,
      isActive: isActive,
      createdAt: DateTime.now(),
    );
  }

  /// Get variant for user
  String getUserVariant(String userId, String testName) {
    if (_userVariants.containsKey('$userId:$testName')) {
      return _userVariants['$userId:$testName']!;
    }

    final test = _tests[testName];
    if (test == null || !test.isActive) {
      return test?.variants.first ?? '';
    }

    // Assign variant based on user ID hash
    final variant = _assignVariant(userId, test);
    _userVariants['$userId:$testName'] = variant;
    _saveVariant(userId, testName, variant);

    return variant;
  }

  /// Assign variant based on hash
  String _assignVariant(String userId, ABTest test) {
    final hash = userId.hashCode % 100;
    final threshold = (test.splitPercentage * 100).toInt();

    if (hash < threshold) {
      return test.variants[0];
    } else {
      return test.variants[hash % test.variants.length];
    }
  }

  /// Track test event
  Future<void> trackTestEvent({
    required String userId,
    required String testName,
    required String eventName,
    Map<String, dynamic>? data,
  }) async {
    final variant = getUserVariant(userId, testName);
    
    // Send to analytics backend
    // await _analyticsService.trackABTestEvent(
    //   userId: userId,
    //   testName: testName,
    //   variant: variant,
    //   eventName: eventName,
    //   data: data,
    // );
  }

  /// Get test statistics
  Future<Map<String, dynamic>> getTestStatistics(String testName) async {
    final test = _tests[testName];
    if (test == null) return {};

    return {
      'testName': testName,
      'variants': test.variants,
      'isActive': test.isActive,
      'createdAt': test.createdAt,
      'statistics': {
        'variant_a': {'users': 0, 'conversions': 0, 'rate': 0.0},
        'variant_b': {'users': 0, 'conversions': 0, 'rate': 0.0},
      },
    };
  }

  /// End test and get winner
  Future<String?> endTest(String testName) async {
    final test = _tests[testName];
    if (test == null) return null;

    // Calculate statistics and determine winner
    final stats = await getTestStatistics(testName);
    final statistics = stats['statistics'] as Map<String, dynamic>;

    double maxRate = 0.0;
    String? winner;

    statistics.forEach((variant, data) {
      final rate = (data as Map<String, dynamic>)['rate'] as double;
      if (rate > maxRate) {
        maxRate = rate;
        winner = variant;
      }
    });

    test.isActive = false;
    test.winner = winner;

    return winner;
  }

  /// Save variant locally
  Future<void> _saveVariant(String userId, String testName, String variant) async {
    // Save to local storage
    // await _localStorage.save('ab_test:$userId:$testName', variant);
  }

  /// Load saved variants
  Future<void> _loadSavedVariants() async {
    // Load from local storage
    // _userVariants = await _localStorage.loadAll('ab_test:');
  }

  /// Check if test is active
  bool isTestActive(String testName) {
    return _tests[testName]?.isActive ?? false;
  }

  /// Get all active tests
  List<ABTest> getActiveTests() {
    return _tests.values.where((test) => test.isActive).toList();
  }
}

/// A/B Test model
class ABTest {
  final String name;
  final List<String> variants;
  final double splitPercentage;
  bool isActive;
  final DateTime createdAt;
  String? winner;

  ABTest({
    required this.name,
    required this.variants,
    required this.splitPercentage,
    required this.isActive,
    required this.createdAt,
    this.winner,
  });
}
