import 'package:flutter/material.dart';
import '../services/date_scheduler_service.dart';

class ProposeDateDialog extends StatefulWidget {
  final String fromUser;
  final String toUser;
  const ProposeDateDialog(
      {super.key, required this.fromUser, required this.toUser});

  @override
  State<ProposeDateDialog> createState() => _ProposeDateDialogState();
}

class _ProposeDateDialogState extends State<ProposeDateDialog> {
  final _controller = TextEditingController();
  bool _loading = false;

  Future<void> _send() async {
    setState(() {
      _loading = true;
    });
    final now = DateTime.now();
    final slot = {
      'start': now.add(Duration(days: 1)).toIso8601String(),
      'end': now.add(Duration(days: 1, hours: 1)).toIso8601String()
    };
    try {
      final res = await DateSchedulerService.proposeDate(
          widget.fromUser, widget.toUser, [slot], _controller.text);
      if (mounted) {
        Navigator.of(context).pop(res);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(null);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Propose a Date'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: 'Message (optional)')),
        ],
      ),
      actions: [
        TextButton(
            onPressed: _loading ? null : () => Navigator.of(context).pop(false),
            child: Text('Cancel')),
        ElevatedButton(onPressed: _loading ? null : _send, child: Text('Send')),
      ],
    );
  }
}
