import 'package:flutter/material.dart';
import '../services/discovery_service.dart';

/// Screen for editing user's profile attributes (height, religion, body type, etc.)
class ProfileAttributesScreen extends StatefulWidget {
  const ProfileAttributesScreen({super.key});

  @override
  State<ProfileAttributesScreen> createState() => _ProfileAttributesScreenState();
}

class _ProfileAttributesScreenState extends State<ProfileAttributesScreen> {
  final DiscoveryService _discoveryService = DiscoveryService();
  
  bool _loading = true;
  bool _saving = false;
  String? _error;
  
  late Map<String, dynamic> filterOptions;
  
  // Profile attributes
  late int height;
  late String religion;
  late String bodyType;
  late String educationLevel;
  late String relationshipGoal;
  late String smoking;
  late String drinking;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    try {
      final options = await _discoveryService.getFilterOptions();
      final prefs = await _discoveryService.getUserFilterPreferences();
      
      if (!mounted) return;
      
      final profile = prefs['profile'] as Map<String, dynamic>? ?? {};
      
      setState(() {
        filterOptions = options;
        height = profile['height'] ?? 0;
        religion = profile['religion'] ?? 'Prefer not to say';
        bodyType = profile['bodyType'] ?? 'Prefer not to say';
        educationLevel = profile['educationLevel'] ?? 'Prefer not to say';
        relationshipGoal = profile['relationshipGoal'] ?? 'Open to Anything';
        smoking = profile['smoking'] ?? 'Prefer not to say';
        drinking = profile['drinking'] ?? 'Prefer not to say';
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!mounted) return;
    setState(() => _saving = true);
    
    try {
      final updated = await _discoveryService.updateProfileAttributes({
        'height': height,
        'religion': religion,
        'bodyType': bodyType,
        'educationLevel': educationLevel,
        'relationshipGoal': relationshipGoal,
        'smoking': smoking,
        'drinking': drinking,
      });
      
      if (!mounted) return;
      
      if (updated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        setState(() => _saving = false);
      } else {
        throw Exception('Failed to save profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile Attributes')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile Attributes')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _loading = true);
                  _loadProfile();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Profile Attributes'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Height input with visual feedback
            _buildHeightInput(),
            const SizedBox(height: 24),

            // Religion dropdown
            _buildDropdown(
              'Religion',
              religion,
              filterOptions['religions'] as List<String>? ?? [],
              (value) => setState(() => religion = value),
            ),
            const SizedBox(height: 20),

            // Body type dropdown
            _buildDropdown(
              'Body Type',
              bodyType,
              filterOptions['bodyTypes'] as List<String>? ?? [],
              (value) => setState(() => bodyType = value),
            ),
            const SizedBox(height: 20),

            // Education level dropdown
            _buildDropdown(
              'Education Level',
              educationLevel,
              filterOptions['educationLevels'] as List<String>? ?? [],
              (value) => setState(() => educationLevel = value),
            ),
            const SizedBox(height: 24),

            const Text(
              'Lifestyle & Preferences',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Relationship goal dropdown
            _buildDropdown(
              'Relationship Goal',
              relationshipGoal,
              filterOptions['relationshipGoals'] as List<String>? ?? [],
              (value) => setState(() => relationshipGoal = value),
            ),
            const SizedBox(height: 20),

            // Smoking dropdown
            _buildDropdown(
              'Smoking',
              smoking,
              filterOptions['smoking'] as List<String>? ?? [],
              (value) => setState(() => smoking = value),
            ),
            const SizedBox(height: 20),

            // Drinking dropdown
            _buildDropdown(
              'Drinking',
              drinking,
              filterOptions['drinking'] as List<String>? ?? [],
              (value) => setState(() => drinking = value),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  disabledBackgroundColor: Colors.grey[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Height (cm)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Enter height',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() => height = int.tryParse(value) ?? 0);
                    }
                  },
                  controller: TextEditingController(text: height > 0 ? height.toString() : ''),
                ),
              ),
              Text(
                height > 0 ? _formatHeight(height) : '--\'--"',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatHeight(int cm) {
    int feet = cm ~/ 30;
    int inches = ((cm % 30) / 2.54).toInt();
    return '$feet\'${inches.toString().padLeft(2, '0')}"';
  }

  Widget _buildDropdown(String label, String value, List<String> options,
      Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.grey[850],
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(option),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ),
      ],
    );
  }
}
