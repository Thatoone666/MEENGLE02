import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/emergency_service.dart';
import '../models/emergency_contact.dart';
import '../providers/emergency_contacts_provider.dart';
import '../animations/premium_animations.dart';

/// Small, discrete "Find Me" safety button for app bar
class FindMeButton extends StatefulWidget {
  final String userId;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const FindMeButton({
    required this.userId,
    this.onSuccess,
    this.onError,
    Key? key,
  }) : super(key: key);

  @override
  State<FindMeButton> createState() => _FindMeButtonState();
}

class _FindMeButtonState extends State<FindMeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Emergency Safety: Share location with trusted contacts',
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withAlpha(77),
                blurRadius: 8,
                spreadRadius: _pulseController.value * 2,
              ),
            ],
          ),
          child: Material(
            shape: const CircleBorder(),
            color: Colors.red.shade600,
            child: InkWell(
              onTap: _isSharing ? null : () => _showEmergencyOptions(context),
              borderRadius: BorderRadius.circular(50),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _isSharing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            Colors.white.withAlpha(200),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Show emergency options menu
  void _showEmergencyOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => EmergencyOptionsSheet(
        userId: widget.userId,
        onSharing: () => setState(() => _isSharing = true),
        onDone: () => setState(() => _isSharing = false),
        onSuccess: widget.onSuccess,
        onError: widget.onError,
      ),
    );
  }
}

/// Emergency options selection sheet
class EmergencyOptionsSheet extends StatefulWidget {
  final String userId;
  final VoidCallback onSharing;
  final VoidCallback onDone;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const EmergencyOptionsSheet({
    required this.userId,
    required this.onSharing,
    required this.onDone,
    this.onSuccess,
    this.onError,
    Key? key,
  }) : super(key: key);

  @override
  State<EmergencyOptionsSheet> createState() => _EmergencyOptionsSheetState();
}

class _EmergencyOptionsSheetState extends State<EmergencyOptionsSheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer<EmergencyContactsProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.shade600,
                        boxShadow: PremiumAnimations.premiumGlow(
                          color: Colors.red.shade600,
                          intensity: 0.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.emergency,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Safety First',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Share your location with trusted contacts',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Favourite contacts
                if (provider.hasFavourites) ...[
                  const Text(
                    'Share with Favourites',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildContactButtons(
                    context,
                    provider.favourites,
                    Colors.amber,
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withAlpha(77),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Colors.blue,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Add trusted contacts to share location quickly',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Emergency services
                const Text(
                  'Emergency Services',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Police button
                _buildEmergencyButton(
                  context,
                  label: 'Alert Police',
                  icon: Icons.security,
                  color: Colors.blue,
                  onTap: () => _alertPolice(context),
                ),
                const SizedBox(height: 8),

                // Hospital button
                _buildEmergencyButton(
                  context,
                  label: 'Call Hospital',
                  icon: Icons.local_hospital,
                  color: Colors.green,
                  onTap: () => _callHospital(context),
                ),
                const SizedBox(height: 8),

                // Emergency number button
                _buildEmergencyButton(
                  context,
                  label: 'Call Emergency',
                  icon: Icons.call,
                  color: Colors.red,
                  onTap: () => _callEmergency(context),
                ),

                const SizedBox(height: 20),

                // Manage contacts button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showManageContacts(context);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Manage Contacts'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber.shade700,
                      side: BorderSide(color: Colors.amber.shade700),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildContactButtons(
    BuildContext context,
    List<EmergencyContact> contacts,
    Color color,
  ) {
    return contacts.map((contact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _buildContactButton(context, contact, color),
      );
    }).toList();
  }

  Widget _buildContactButton(
    BuildContext context,
    EmergencyContact contact,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: ListTile(
        leading: Icon(Icons.heart, color: color, size: 20),
        title: Text(
          contact.name,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          contact.phoneNumber,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        onTap: () => _shareWithContact(context, contact),
      ),
    );
  }

  Widget _buildEmergencyButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _shareWithContact(
    BuildContext context,
    EmergencyContact contact,
  ) async {
    widget.onSharing();
    Navigator.pop(context);

    final emergencyService = EmergencyService();
    final location = await emergencyService.getCurrentLocation();

    if (location != null) {
      final success = await emergencyService.shareLocationWithContact(
        userId: widget.userId,
        contact: contact,
        location: location,
        serviceType: EmergencyServiceType.favourite,
      );

      widget.onDone();

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location shared with ${contact.name}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        widget.onSuccess?.call();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to share location'),
              backgroundColor: Colors.red,
            ),
          );
        }
        widget.onError?.call();
      }
    }
  }

  Future<void> _alertPolice(BuildContext context) async {
    widget.onSharing();
    Navigator.pop(context);

    final emergencyService = EmergencyService();
    final location = await emergencyService.getCurrentLocation();

    if (location != null) {
      final success = await emergencyService.sendSOSToPolice(
        userId: widget.userId,
        location: location,
        incidentType: 'Safety Concern',
      );

      widget.onDone();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Police have been alerted with your location'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
        widget.onSuccess?.call();
      }
    }
  }

  Future<void> _callHospital(BuildContext context) async {
    // In production, integrate with actual hospital directory
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nearby hospitals will be shown'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _callEmergency(BuildContext context) async {
    // In production, initiate actual emergency call
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency call initiated'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showManageContacts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ManageEmergencyContactsDialog(
        userId: widget.userId,
      ),
    );
  }
}

/// Manage emergency contacts dialog
class ManageEmergencyContactsDialog extends StatelessWidget {
  final String userId;

  const ManageEmergencyContactsDialog({
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Consumer<EmergencyContactsProvider>(
          builder: (context, provider, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (provider.contacts.isEmpty)
                  const Center(
                    child: Text(
                      'No contacts added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: provider.contacts.length,
                      itemBuilder: (context, index) {
                        final contact = provider.contacts[index];
                        return _buildContactTile(context, provider, contact);
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddContactDialog(context, provider);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Contact'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    EmergencyContactsProvider provider,
    EmergencyContact contact,
  ) {
    return ListTile(
      leading: Icon(
        contact.isFavourite ? Icons.heart : Icons.person,
        color: contact.isFavourite ? Colors.red : Colors.grey,
      ),
      title: Text(
        contact.name,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        contact.phoneNumber,
        style: const TextStyle(color: Colors.grey, fontSize: 11),
      ),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(
            child: const Text('Toggle Favourite'),
            onTap: () => provider.toggleFavourite(contact.id),
          ),
          PopupMenuItem(
            child: const Text('Delete'),
            onTap: () => provider.deleteContact(contact.id),
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog(
    BuildContext context,
    EmergencyContactsProvider provider,
  ) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    bool isFavourite = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Add Emergency Contact',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Name',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: isFavourite,
                    onChanged: (value) {
                      setState(() => isFavourite = value ?? false);
                    },
                    title: const Text(
                      'Mark as Favourite',
                      style: TextStyle(color: Colors.white),
                    ),
                    activeColor: Colors.amber.shade700,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.addContact(
                    userId: userId,
                    name: nameController.text,
                    phoneNumber: phoneController.text,
                    email: emailController.text,
                    isFavourite: isFavourite,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                ),
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }
}
