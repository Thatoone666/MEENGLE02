import 'package:flutter/material.dart';
import '../services/discovery_service.dart';
import '../models/meengle_tier_system.dart';

/// Screen for managing swipe filter preferences
class FilterPreferencesScreen extends StatefulWidget {
  const FilterPreferencesScreen({super.key});

  @override
  State<FilterPreferencesScreen> createState() => _FilterPreferencesScreenState();
}

class _FilterPreferencesScreenState extends State<FilterPreferencesScreen> {
  final DiscoveryService _discoveryService = DiscoveryService();
  
  late Map<String, dynamic> filterOptions;
  late Map<String, dynamic> currentPreferences;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  // Filter state variables
  late int minAge;
  late int maxAge;
  late int minHeight;
  late int maxHeight;
  late int maxDistance;
  
  late List<String> selectedReligions;
  late List<String> selectedBodyTypes;
  late List<String> selectedEducationLevels;
  late List<String> selectedRelationshipGoals;
  late List<String> selectedSmoking;
  late List<String> selectedDrinking;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    if (!mounted) return;
    try {
      final options = await _discoveryService.getFilterOptions();
      final prefs = await _discoveryService.getUserFilterPreferences();
      
      if (!mounted) return;
      
      final filterPrefs = prefs['preferences'] as Map<String, dynamic>? ?? {};
      
      setState(() {
        filterOptions = options;
        currentPreferences = filterPrefs;
        
        // Initialize filter values
        minAge = filterPrefs['ageRange']?['min'] ?? 18;
        maxAge = filterPrefs['ageRange']?['max'] ?? 99;
        minHeight = filterPrefs['heightRange']?['min'] ?? 140;
        maxHeight = filterPrefs['heightRange']?['max'] ?? 220;
        maxDistance = filterPrefs['maxDistance'] ?? 50;
        
        selectedReligions = List<String>.from(filterPrefs['religions'] ?? []);
        selectedBodyTypes = List<String>.from(filterPrefs['bodyTypes'] ?? []);
        selectedEducationLevels = List<String>.from(filterPrefs['educationLevels'] ?? []);
        selectedRelationshipGoals = List<String>.from(filterPrefs['relationshipGoals'] ?? []);
        selectedSmoking = List<String>.from(filterPrefs['smoking'] ?? []);
        selectedDrinking = List<String>.from(filterPrefs['drinking'] ?? []);
        
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

  Future<void> _saveFilters() async {
    if (!mounted) return;
    setState(() => _saving = true);
    
    try {
      final updated = await _discoveryService.updateFilterPreferences({
        'ageRange': {'min': minAge, 'max': maxAge},
        'heightRange': {'min': minHeight, 'max': maxHeight},
        'maxDistance': maxDistance,
        'religions': selectedReligions,
        'bodyTypes': selectedBodyTypes,
        'educationLevels': selectedEducationLevels,
        'relationshipGoals': selectedRelationshipGoals,
        'smoking': selectedSmoking,
        'drinking': selectedDrinking,
      });
      
      if (!mounted) return;
      
      if (updated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filters updated successfully!')),
        );
        setState(() => _saving = false);
      } else {
        throw Exception('Failed to save filters');
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
        appBar: AppBar(title: const Text('Filter Preferences')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Filter Preferences')),
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
                  _loadFilters();
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
        title: const Text('Filter Preferences'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Age & Distance'),
            _buildRangeSlider('Age Range', minAge, maxAge, 18, 99, (min, max) {
              setState(() {
                minAge = min;
                maxAge = max;
              });
            }),
            const SizedBox(height: 20),
            _buildSlider('Max Distance (km)', maxDistance.toDouble(), 1, 200,
                (value) => setState(() => maxDistance = value.toInt())),
            const SizedBox(height: 24),

            _buildSectionHeader('Physical Attributes'),
            _buildRangeSlider('Height Range (cm)', minHeight, maxHeight, 140, 220,
                (min, max) {
              setState(() {
                minHeight = min;
                maxHeight = max;
              });
            }),
            const SizedBox(height: 20),
            _buildMultiSelect(
              'Body Type',
              filterOptions['bodyTypes'] as List<String>? ?? [],
              selectedBodyTypes,
              (selected) => setState(() => selectedBodyTypes = selected),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Lifestyle'),
            _buildMultiSelect(
              'Religion',
              filterOptions['religions'] as List<String>? ?? [],
              selectedReligions,
              (selected) => setState(() => selectedReligions = selected),
            ),
            const SizedBox(height: 20),
            _buildMultiSelect(
              'Smoking',
              filterOptions['smoking'] as List<String>? ?? [],
              selectedSmoking,
              (selected) => setState(() => selectedSmoking = selected),
            ),
            const SizedBox(height: 20),
            _buildMultiSelect(
              'Drinking',
              filterOptions['drinking'] as List<String>? ?? [],
              selectedDrinking,
              (selected) => setState(() => selectedDrinking = selected),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Relationship Preferences'),
            _buildMultiSelect(
              'Relationship Goals',
              filterOptions['relationshipGoals'] as List<String>? ?? [],
              selectedRelationshipGoals,
              (selected) => setState(() => selectedRelationshipGoals = selected),
            ),
            const SizedBox(height: 20),
            _buildMultiSelect(
              'Education Level',
              filterOptions['educationLevels'] as List<String>? ?? [],
              selectedEducationLevels,
              (selected) => setState(() => selectedEducationLevels = selected),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveFilters,
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
                        'Save Filters',
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRangeSlider(String label, int min, int max, int globalMin,
      int globalMax, Function(int, int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: RangeValues(min.toDouble(), max.toDouble()),
          onChanged: (values) =>
              onChanged(values.start.toInt(), values.end.toInt()),
          min: globalMin.toDouble(),
          max: globalMax.toDouble(),
          activeColor: Colors.greenAccent,
          inactiveColor: Colors.grey[800],
          labels: RangeLabels('$min', '$max'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$min', style: const TextStyle(color: Colors.white70)),
            Text('$max', style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            Text(
              '${value.toInt()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Slider(
          value: value,
          onChanged: onChanged,
          min: min,
          max: max,
          activeColor: Colors.greenAccent,
          inactiveColor: Colors.grey[800],
        ),
      ],
    );
  }

  Widget _buildMultiSelect(String label, List<String> options,
      List<String> selected, Function(List<String>) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (value) {
                final newSelected = List<String>.from(selected);
                if (value) {
                  newSelected.add(option);
                } else {
                  newSelected.remove(option);
                }
                onChanged(newSelected);
              },
              backgroundColor: Colors.grey[900],
              selectedColor: Colors.greenAccent,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? Colors.greenAccent : Colors.grey[700]!,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
