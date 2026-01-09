import 'package:flutter/material.dart';
import 'package:meengle_flutter/services/boost_service.dart';

class BoostScreen extends StatefulWidget {
  const BoostScreen({super.key});

  @override
  State<BoostScreen> createState() => _BoostScreenState();
}

class _BoostScreenState extends State<BoostScreen> {
  bool _loading = false;
  String? _message;

  Future<void> _boostNow() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final ok = await BoostService.boostNow();
      setState(() {
        _message = ok ? 'Boost activated!' : 'Boost failed.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boost Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
                'Boost your profile to increase visibility for 30 minutes.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _boostNow,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Boost Now'),
            ),
            const SizedBox(height: 12),
            if (_message != null) Text(_message!),
          ],
        ),
      ),
    );
  }
}
