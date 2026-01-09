import 'package:flutter/material.dart';
import '../services/events_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  bool _creating = false;

  void _create() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _creating = true);
    try {
      await EventsService.createEvent(
          {'title': _title, 'description': _description});
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create event')));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Event')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  onSaved: (v) => _title = v ?? '',
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null),
              TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onSaved: (v) => _description = v ?? ''),
              SizedBox(height: 12),
              _creating
                  ? CircularProgressIndicator()
                  : ElevatedButton(onPressed: _create, child: Text('Create'))
            ],
          ),
        ),
      ),
    );
  }
}
