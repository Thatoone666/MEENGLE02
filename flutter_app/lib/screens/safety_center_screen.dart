import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/safety_center.dart';
import '../providers/safety_provider.dart';

class SafetyCenterScreen extends StatefulWidget {
  const SafetyCenterScreen({super.key});

  @override
  State<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends State<SafetyCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Load safety data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SafetyProvider>().loadSafetyData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SafetyProvider>(
      builder: (context, safetyProvider, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Safety Center'),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Trust Score Header
              if (safetyProvider.trustScore != null)
                _buildTrustScoreHeader(context, safetyProvider.trustScore)
              else
                const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
              // Tab bar
              TabBar(
                controller: _tabController,
                labelColor: Colors.blueAccent,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blueAccent,
                tabs: const [
                  Tab(text: 'Verification'),
                  Tab(text: 'Blocking'),
                  Tab(text: 'Emergency'),
                  Tab(text: 'Tips'),
                ],
              ),
              // Tab views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVerificationTab(context, safetyProvider),
                    _buildBlockingTab(context, safetyProvider),
                    _buildEmergencyTab(context, safetyProvider),
                    _buildTipsTab(context, safetyProvider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrustScoreHeader(BuildContext context, Map<String, dynamic>? data) {
    final score = data?['trust_score'] ?? 75;
    final verifications = data?['verifications_completed'] ?? 0;
    final isVerified = (data?['is_verified'] ?? false);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent.withValues(alpha: 0.8), Colors.purpleAccent.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trust Score',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$score%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Overall Safety',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      score > 70 ? Colors.green : score > 40 ? Colors.orange : Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScoreStat('Verifications', verifications.toString()),
              _buildScoreStat('Verified', isVerified ? 'Yes' : 'No'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildVerificationTab(BuildContext context, SafetyProvider safetyProvider) {
    final prefs = safetyProvider.preferences;
    final status = safetyProvider.verificationStatus;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Verification Methods'),
            const SizedBox(height: 12),
            _buildVerificationCard(
              icon: Icons.videocam,
              title: 'Video Verification',
              description: 'Verify your identity with a live video',
              isCompleted: status?['video_verified'] ?? false,
              onTap: () => _showVideoVerificationDialog(context),
            ),
            _buildVerificationCard(
              icon: Icons.camera_alt,
              title: 'Selfie Verification',
              description: 'Quick selfie for instant verification',
              isCompleted: status?['selfie_verified'] ?? false,
              onTap: () => _showSelfieVerificationDialog(context),
            ),
            _buildVerificationCard(
              icon: Icons.description,
              title: 'Document Verification',
              description: 'Verify with government ID',
              isCompleted: status?['document_verified'] ?? false,
              onTap: () => _showDocumentVerificationDialog(context),
            ),
            _buildVerificationCard(
              icon: Icons.phone,
              title: 'Phone Verification',
              description: 'Verify phone number with SMS',
              isCompleted: status?['phone_verified'] ?? false,
              onTap: () => _showPhoneVerificationDialog(context),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Privacy Settings'),
            const SizedBox(height: 12),
            _buildToggleSetting(
              title: 'Block Screenshots',
              subtitle: 'Prevent users from taking screenshots of your profile',
              value: prefs.blockScreenshots,
              onChanged: (value) {
                safetyProvider.updateScreenProtection(value, prefs.disableScreenshare);
              },
            ),
            _buildToggleSetting(
              title: 'Disable Screen Share',
              subtitle: 'Prevent screen sharing in video calls',
              value: prefs.disableScreenshare,
              onChanged: (value) {
                safetyProvider.updateScreenProtection(prefs.blockScreenshots, value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockingTab(BuildContext context, SafetyProvider safetyProvider) {
    final users = safetyProvider.blockedUsers;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Blocked Users (${users.length})'),
            const SizedBox(height: 12),
            if (users.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.block, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        'No blocked users',
                        style: TextStyle(color: Colors.grey.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...users.map((user) => _buildBlockedUserCard(context, safetyProvider, user)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyTab(BuildContext context, SafetyProvider safetyProvider) {
    final contacts = safetyProvider.emergencyContacts;
    final prefs = safetyProvider.preferences;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Emergency Contacts'),
                FloatingActionButton.small(
                  onPressed: () => _showAddEmergencyContactDialog(context, safetyProvider),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (contacts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.emergency, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      const Text('No emergency contacts yet'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _showAddEmergencyContactDialog(context, safetyProvider),
                        child: const Text('Add Contact'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: contacts
                    .map((contact) => _buildEmergencyContactCard(context, safetyProvider, contact))
                    .toList(),
              ),
            const SizedBox(height: 24),
            _buildSectionTitle('Share Location With Contacts'),
            const SizedBox(height: 12),
            _buildToggleSetting(
              title: 'Enable Location Sharing',
              subtitle: 'Share your live location with emergency contacts',
              value: prefs.enableLocationSharing,
              onChanged: (value) {
                safetyProvider.updateLocationSharing(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsTab(BuildContext context, SafetyProvider safetyProvider) {
    final tips = safetyProvider.safetyTips;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Safety Tips & Resources'),
            const SizedBox(height: 12),
            if (tips.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.lightbulb, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      const Text('Safety tips coming soon'),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: tips
                    .map((tip) => _buildSafetyTipCard(tip))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTipCard(SafetyTip tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(tip.icon, color: Colors.blueAccent),
        title: Text(
          tip.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          tip.category,
          style: TextStyle(fontSize: 12, color: Colors.grey.withValues(alpha: 0.7)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(tip.content),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.withValues(alpha: 0.1) : Colors.blueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isCompleted ? Colors.green : Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: Colors.grey.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle, color: Colors.green)
              else
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockedUserCard(BuildContext context, SafetyProvider safetyProvider, BlockedUser user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(user.profileImage),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (user.reason != null)
                    Text(
                      'Reason: ${user.reason}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.withValues(alpha: 0.7)),
                    ),
                  Text(
                    'Blocked ${_formatDate(user.blockedAt)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => _showUnblockDialog(context, safetyProvider, user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactCard(BuildContext context, SafetyProvider safetyProvider, EmergencyContact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.person_outline, size: 32, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    contact.phoneNumber,
                    style: TextStyle(fontSize: 12, color: Colors.grey.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            if (contact.isVerified)
              const Icon(Icons.verified, size: 20, color: Colors.green)
            else
              const Icon(Icons.schedule, size: 20, color: Colors.orange),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => _showRemoveContactDialog(context, safetyProvider, contact),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  void _showVideoVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Verification'),
        content: const Text('Record a 30-second video showing your face clearly. Ensure good lighting and avoid masks.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video verification submitted for review')),
              );
            },
            child: const Text('Start Recording'),
          ),
        ],
      ),
    );
  }

  void _showSelfieVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selfie Verification'),
        content: const Text('Take a clear selfie with good lighting. Avoid filters or heavy makeup.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selfie submitted for verification')),
              );
            },
            child: const Text('Take Selfie'),
          ),
        ],
      ),
    );
  }

  void _showDocumentVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Verification'),
        content: const Text('Upload a clear photo of your government-issued ID. Ensure all details are visible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document submitted for verification')),
              );
            },
            child: const Text('Upload Document'),
          ),
        ],
      ),
    );
  }

  void _showPhoneVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phone Verification'),
        content: const Text('We\'ll send you an SMS code to verify your phone number.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('SMS code sent to your phone')),
              );
            },
            child: const Text('Send Code'),
          ),
        ],
      ),
    );
  }

  void _showUnblockDialog(BuildContext context, SafetyProvider safetyProvider, BlockedUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock User'),
        content: Text('Are you sure you want to unblock ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.name} has been unblocked')),
              );
            },
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }

  void _showAddEmergencyContactDialog(BuildContext context, SafetyProvider safetyProvider) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${nameController.text} added as emergency contact')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showRemoveContactDialog(BuildContext context, SafetyProvider safetyProvider, EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Contact'),
        content: Text('Are you sure you want to remove ${contact.name} from your emergency contacts?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${contact.name} has been removed')),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else {
      return '${(diff.inDays / 30).floor()} months ago';
    }
  }
}
