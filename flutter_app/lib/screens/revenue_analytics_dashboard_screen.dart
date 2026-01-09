import 'package:flutter/material.dart';
import '../services/revenue_analytics_service.dart';
import '../services/analytics_service.dart';

/// Analytics dashboard for viewing revenue metrics and conversion funnels
class RevenueAnalyticsDashboardScreen extends StatefulWidget {
  const RevenueAnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<RevenueAnalyticsDashboardScreen> createState() =>
      _RevenueAnalyticsDashboardScreenState();
}

class _RevenueAnalyticsDashboardScreenState
    extends State<RevenueAnalyticsDashboardScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logEvent('analytics_dashboard_opened', {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          '?? Revenue Analytics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          /// Tab navigation
          Container(
            color: const Color(0xFF1A1A1A),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab('Overview', 0),
                  _buildTab('Paywalls', 1),
                  _buildTab('Conversions', 2),
                  _buildTab('Trials', 3),
                  _buildTab('Boosts', 4),
                ],
              ),
            ),
          ),

          /// Tab content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build tab button
  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? const Color(0xFFD4AF37)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Build tab content
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildPaywallsTab();
      case 2:
        return _buildConversionsTab();
      case 3:
        return _buildTrialsTab();
      case 4:
        return _buildBoostsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  /// Overview Tab - Key metrics summary
  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        /// Metric cards
        _buildMetricCard(
          title: 'Monthly Revenue',
          value: '\$45,230',
          change: '+12%',
          changePositive: true,
          icon: '??',
        ),
        _buildMetricCard(
          title: 'Active Subscribers',
          value: '2,847',
          change: '+8%',
          changePositive: true,
          icon: '??',
        ),
        _buildMetricCard(
          title: 'Conversion Rate',
          value: '3.8%',
          change: '+0.2%',
          changePositive: true,
          icon: '??',
        ),
        _buildMetricCard(
          title: 'Trial to Paid',
          value: '42%',
          change: '+5%',
          changePositive: true,
          icon: '??',
        ),

        const SizedBox(height: 24),

        /// Revenue by source
        const Text(
          'Revenue by Source',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _buildRevenueSourceRow('Premium Tiers', 28000, 0.62),
        _buildRevenueSourceRow('Boosts', 12000, 0.27),
        _buildRevenueSourceRow('Trials Converted', 5230, 0.11),
      ],
    );
  }

  /// Paywalls Tab - Paywall performance metrics
  Widget _buildPaywallsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paywall Performance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        /// Paywall metrics
        _buildMetricCard(
          title: 'Total Impressions',
          value: '47,234',
          change: '+15% today',
          changePositive: true,
          icon: '??',
        ),
        _buildMetricCard(
          title: 'Click-Through Rate',
          value: '23.4%',
          change: '+2.1% today',
          changePositive: true,
          icon: '??',
        ),

        const SizedBox(height: 24),

        /// Feature-specific paywall performance
        const Text(
          'By Feature',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _buildPaywallFeatureRow('Video Profiles', 12000, 28, 3360),
        _buildPaywallFeatureRow('Super Likes', 8500, 31, 2635),
        _buildPaywallFeatureRow('Verified Badge', 6200, 18, 1116),
        _buildPaywallFeatureRow('Spotlight', 5100, 25, 1275),
      ],
    );
  }

  /// Conversions Tab - Conversion funnel
  Widget _buildConversionsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conversion Funnel',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        /// Funnel visualization
        _buildFunnelStep(1, 'Paywall Shown', 47234, 100),
        _buildFunnelStep(2, 'Paywall Clicked', 11045, 23.4),
        _buildFunnelStep(3, 'Tier Screen Viewed', 8950, 81),
        _buildFunnelStep(4, 'Checkout Started', 5370, 60),
        _buildFunnelStep(5, 'Purchase Completed', 2847, 53),

        const SizedBox(height: 24),

        /// Conversion insights
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Conversion Insights',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Overall paywall CTR: 23.4%\n'
                '• Average time on tier screen: 45 seconds\n'
                '• Top converting feature: Super Likes (31% CTR)\n'
                '• Mobile vs Web CTR similar',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Trials Tab - Free trial metrics
  Widget _buildTrialsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Free Trial Performance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        /// Trial metrics
        _buildMetricCard(
          title: 'Trials Started',
          value: '1,240',
          change: '+18% this week',
          changePositive: true,
          icon: '??',
        ),
        _buildMetricCard(
          title: 'Conversion Rate',
          value: '42%',
          change: '+5% this week',
          changePositive: true,
          icon: '??',
        ),
        _buildMetricCard(
          title: 'Avg Trial Duration',
          value: '6.2 days',
          change: 'of 7 available',
          changePositive: true,
          icon: '??',
        ),

        const SizedBox(height: 24),

        /// Trial source breakdown
        const Text(
          'Trials by Source',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _buildTrialSourceRow('Onboarding Screen', 680, 54.8),
        _buildTrialSourceRow('Paywall CTR', 340, 27.4),
        _buildTrialSourceRow('Account Deletion', 220, 17.8),
      ],
    );
  }

  /// Boosts Tab - In-app boost metrics
  Widget _buildBoostsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'In-App Boosts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        /// Boost metrics
        _buildMetricCard(
          title: 'Boosts Purchased',
          value: '3,247',
          change: '+22% this month',
          changePositive: true,
          icon: '??',
        ),
        _buildMetricCard(
          title: 'Boost Revenue',
          value: '\$12,000',
          change: '+25% this month',
          changePositive: true,
          icon: '??',
        ),

        const SizedBox(height: 24),

        /// Popular boosts
        const Text(
          'Top Boosts',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _buildBoostRow('10 Super Likes', 1240, 38),
        _buildBoostRow('Spotlight 24h', 890, 27),
        _buildBoostRow('Boost Profile', 650, 20),
        _buildBoostRow('Incognito Week', 467, 15),
      ],
    );
  }

  /// Metric card widget
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required bool changePositive,
    required String icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  color: changePositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          Text(icon, style: const TextStyle(fontSize: 32)),
        ],
      ),
    );
  }

  /// Revenue source row
  Widget _buildRevenueSourceRow(String label, int amount, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                '\$${amount.toString()}',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation(Color(0xFFD4AF37)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  /// Paywall feature row
  Widget _buildPaywallFeatureRow(
    String feature,
    int impressions,
    int ctr,
    int clicks,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$impressions impressions',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$ctr%',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$clicks clicks',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Funnel step visualization
  Widget _buildFunnelStep(
    int step,
    String label,
    int count,
    double percentage,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$step. $label',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation(Color(0xFFD4AF37)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  /// Trial source row
  Widget _buildTrialSourceRow(String source, int count, double percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            source,
            style: const TextStyle(color: Colors.white70),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Boost row
  Widget _buildBoostRow(String boost, int purchases, double percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            boost,
            style: const TextStyle(color: Colors.white70),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$purchases',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
