import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/analytics_service.dart';

class AISuggestionsDialog extends StatefulWidget {
  final String userId;
  final String matchId;
  const AISuggestionsDialog(
      {super.key, required this.userId, required this.matchId});

  @override
  State<AISuggestionsDialog> createState() => _AISuggestionsDialogState();
}

class _AISuggestionsDialogState extends State<AISuggestionsDialog> {
  List<String> _prompts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final p = await AIService.getIcebreakers(widget.userId, widget.matchId);
      setState(() {
        _prompts = p;
        _loading = false;
      });
      AnalyticsService.track('ai_openers_shown', {'count': p.length});
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('AI Suggestions'),
      content: _loading
          ? Center(child: CircularProgressIndicator())
          : SizedBox(
              width: 300,
              child: ListView(
                shrinkWrap: true,
                children: _prompts
                    .map((t) => ListTile(
                        title: Text(t),
                        onTap: () => Navigator.of(context).pop(t)))
                    .toList(),
              ),
            ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(), child: Text('Close'))
      ],
    );
  }
}
