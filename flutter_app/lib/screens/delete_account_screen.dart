import 'package:flutter/material.dart';
import '../services/account_deletion_service.dart';
import '../services/api_service.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  
  bool _agreeToTerms = false;
  bool _isDeleting = false;
  int _step = 1; // 1: Warning, 2: Confirmation, 3: Reason, 4: Processing

  @override
  void dispose() {
    _passwordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm you understand the consequences')),
      );
      return;
    }

    setState(() => _isDeleting = true);

    try {
      // Call backend to delete account
      final success = await ApiService.deleteAccount(
        password: _passwordController.text,
        reason: _reasonController.text,
      );

      if (success) {
        // Navigate to login after deletion
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your account has been deleted successfully')),
          );
          // Navigate to login or exit app
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_step == 1) {
          return true;
        }
        setState(() => _step = _step - 1);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Delete Account'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_step == 1) {
                Navigator.pop(context);
              } else {
                setState(() => _step = _step - 1);
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildStepContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 1:
        return _buildWarningStep();
      case 2:
        return _buildConfirmationStep();
      case 3:
        return _buildReasonStep();
      case 4:
        return _buildProcessingStep();
      default:
        return _buildWarningStep();
    }
  }

  Widget _buildWarningStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warning Icon
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent.withAlpha(51),
            ),
            child: const Icon(Icons.warning, size: 40, color: Colors.redAccent),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        const Text(
          'Delete Your Account',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Warning message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.redAccent.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.redAccent.withAlpha(102)),
          ),
          child: const Text(
            'This action cannot be undone. Once deleted, your account and all associated data will be permanently removed.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),

        // What gets deleted
        const Text(
          'What will be deleted:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildDeleteItem('??? Your profile and all personal information'),
        _buildDeleteItem('?? All your chat messages and conversations'),
        _buildDeleteItem('?? Your matches and match history'),
        _buildDeleteItem('?? All photos and media you uploaded'),
        _buildDeleteItem('?? Boosts, coins, and paid features'),
        _buildDeleteItem('?? Payment and billing information'),

        const SizedBox(height: 32),

        // Continue button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => setState(() => _step = 2),
            child: const Text(
              'I Understand, Continue',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Cancel button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Are You Sure?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        const Text(
          'Please confirm that you want to permanently delete your account. This step cannot be reversed.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 32),

        // Confirmation checkboxes
        _buildCheckboxTile(
          'I understand my account will be permanently deleted',
          _agreeToTerms,
          (value) => setState(() => _agreeToTerms = value ?? false),
        ),
        const SizedBox(height: 12),
        _buildCheckboxTile(
          'I understand this action cannot be undone',
          _agreeToTerms,
          (value) => setState(() => _agreeToTerms = value ?? false),
        ),

        const SizedBox(height: 32),

        // Continue button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _agreeToTerms ? () => setState(() => _step = 3) : null,
            child: const Text(
              'Continue to Next Step',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile(String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      checkColor: Colors.white,
      activeColor: Colors.redAccent,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildReasonStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why Are You Leaving?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '(Optional) Help us improve by telling us why',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // Reason categories
        _buildReasonButton('Not finding matches', () {
          _reasonController.text = 'Not finding matches';
        }),
        const SizedBox(height: 8),
        _buildReasonButton('Too many fake profiles', () {
          _reasonController.text = 'Too many fake profiles';
        }),
        const SizedBox(height: 8),
        _buildReasonButton('Privacy concerns', () {
          _reasonController.text = 'Privacy concerns';
        }),
        const SizedBox(height: 8),
        _buildReasonButton('Not interested anymore', () {
          _reasonController.text = 'Not interested anymore';
        }),
        const SizedBox(height: 8),
        _buildReasonButton('App performance issues', () {
          _reasonController.text = 'App performance issues';
        }),
        const SizedBox(height: 8),
        _buildReasonButton('Other', () {
          _reasonController.clear();
        }),

        const SizedBox(height: 24),

        // Custom reason text field
        TextField(
          controller: _reasonController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Tell us more... (optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Delete button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => setState(() => _step = 4),
            child: const Text(
              'Proceed to Verification',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonButton(String reason, VoidCallback onTap) {
    bool isSelected = _reasonController.text == reason;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.redAccent : Colors.grey.withAlpha(77),
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.redAccent.withAlpha(26) : Colors.transparent,
        ),
        child: Text(
          reason,
          style: TextStyle(
            color: isSelected ? Colors.redAccent : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent.withAlpha(51),
          ),
          child: const Icon(Icons.lock, size: 40, color: Colors.redAccent),
        ),
        const SizedBox(height: 24),

        const Text(
          'Verify Your Password',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        const Text(
          'Enter your password to confirm account deletion',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Password field
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Delete button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isDeleting ? null : _deleteAccount,
            child: _isDeleting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Permanently Delete Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 12),

        // Cancel button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _isDeleting ? null : () => setState(() => _step = 3),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }
}
