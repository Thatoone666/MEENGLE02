import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({required this.email});

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController tokenController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mail_outline, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              'Verify your email',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'We sent a verification link to ${widget.email}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: tokenController,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                errorText: errorMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verifyEmail,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Verify'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _resendEmail,
              child: const Text('Resend Email'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyEmail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await Provider.of<ApiService>(context, listen: false)
          .post('/auth/verify-email', {
        'token': tokenController.text,
      });

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email verified!')),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          errorMessage = response['error'] ?? 'Verification failed';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _resendEmail() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification email resent')),
    );
  }

  @override
  void dispose() {
    tokenController.dispose();
    super.dispose();
  }
}
