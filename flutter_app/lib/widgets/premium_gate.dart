import 'package:flutter/material.dart';
import '../services/premium_service.dart';
import '../screens/premium_screen.dart';

class PremiumGate extends StatefulWidget {
  final Widget child;
  final String email;
  const PremiumGate({super.key, required this.child, required this.email});

  @override
  State<PremiumGate> createState() => _PremiumGateState();
}

class _PremiumGateState extends State<PremiumGate> {
  bool _isPremium = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final p = await PremiumService.isPremium();
    setState(() {
      _isPremium = p;
      _loading = false;
    });
  }

  void _goPremium() {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (_) => PremiumScreen(email: widget.email)))
        .then((_) => _check());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Center(child: CircularProgressIndicator());
    if (_isPremium) return widget.child;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('This is a premium feature.'),
          SizedBox(height: 8),
          ElevatedButton(onPressed: _goPremium, child: Text('Go Premium'))
        ],
      ),
    );
  }
}
