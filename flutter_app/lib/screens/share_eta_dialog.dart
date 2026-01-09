import 'package:flutter/material.dart';
import '../services/safety_service.dart';

class ShareETADialog extends StatefulWidget {
  final String matchId;
  // Optional injected service for easier testing (implements shareEta)
  final dynamic safetyService;

  const ShareETADialog({super.key, required this.matchId, this.safetyService});

  @override
  State<ShareETADialog> createState() => _ShareETADialogState();
}

class _ShareETADialogState extends State<ShareETADialog> {
  Duration _eta = Duration(minutes: 30);
  bool _sharing = false;

  void _send() async {
    setState(() => _sharing = true);
    try {
      // Try to call the real SafetyService signature first
      final etaDate = DateTime.now().add(_eta);
      final etaIso = etaDate.toIso8601String();
      if (widget.safetyService == null) {
        // use the real static service
        await SafetyService.shareEta('', widget.matchId, etaIso);
      } else {
        final svc = widget.safetyService;
        // svc is dynamic (test fake or real instance). Try the real signature (from,to,etaIso)
        try {
          await svc.shareEta('', widget.matchId, etaIso);
        } catch (e) {
          // Fallback: some tests provide a fake with signature shareEta(matchId, DateTime)
          await svc.shareEta(widget.matchId, etaDate);
        }
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to share ETA')));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Share your ETA'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('How long until you arrive?'),
          SizedBox(height: 12),
          DropdownButton<Duration>(
            value: _eta,
            items: [15, 30, 45, 60]
                .map((m) => DropdownMenuItem(
                      value: Duration(minutes: m),
                      child: Text('$m minutes'),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _eta = v);
            },
          )
        ],
      ),
      actions: [
        TextButton(
            onPressed: _sharing ? null : () => Navigator.of(context).pop(false),
            child: Text('Cancel')),
        ElevatedButton(
            onPressed: _sharing ? null : _send,
            child: _sharing
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Share')),
      ],
    );
  }
}
