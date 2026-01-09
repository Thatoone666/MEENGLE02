import 'package:flutter/material.dart';
import '../services/boost_service.dart';

class ScheduleBoostDialog extends StatefulWidget {
  const ScheduleBoostDialog({super.key});

  @override
  State<ScheduleBoostDialog> createState() => _ScheduleBoostDialogState();
}

class _ScheduleBoostDialogState extends State<ScheduleBoostDialog> {
  DateTime _start = DateTime.now().add(Duration(minutes: 5));
  int _minutes = 30;
  bool _scheduling = false;

  void _schedule() async {
    setState(() => _scheduling = true);
    try {
      await BoostService.scheduleBoost(
          '', _start.toIso8601String(), _minutes, {});
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to schedule boost')));
      }
    } finally {
      if (mounted) setState(() => _scheduling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Schedule Boost'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Start time'),
            subtitle: Text(_start.toLocal().toString()),
            trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  final picked = await showDatePicker(
                      context: context,
                      initialDate: _start,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 30)));
                  if (picked != null) setState(() => _start = picked);
                }),
          ),
          Row(children: [
            Text('Duration:'),
            SizedBox(width: 8),
            DropdownButton<int>(
                value: _minutes,
                items: [15, 30, 45, 60]
                    .map((m) =>
                        DropdownMenuItem(value: m, child: Text('$m min')))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _minutes = v);
                })
          ])
        ],
      ),
      actions: [
        TextButton(
            onPressed:
                _scheduling ? null : () => Navigator.of(context).pop(false),
            child: Text('Cancel')),
        ElevatedButton(
            onPressed: _scheduling ? null : _schedule,
            child: _scheduling
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Schedule')),
      ],
    );
  }
}
