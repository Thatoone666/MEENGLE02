import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/voice_service.dart';

class VoicePlaceholder extends StatefulWidget {
  final VoiceService voiceService;
  const VoicePlaceholder({super.key, required this.voiceService});

  @override
  State<VoicePlaceholder> createState() => _VoicePlaceholderState();
}

class _VoicePlaceholderState extends State<VoicePlaceholder> {
  bool _recording = false;
  bool _uploading = false;

  void _toggleRecord() async {
    setState(() => _recording = !_recording);
    if (!_recording) {
      // simulate an upload
      setState(() => _uploading = true);
      // call the VoiceService upload method (stubbed in services)
      await VoiceService.uploadSample(Uint8List(128));
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice sample uploaded')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Voice Message'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_recording ? Icons.mic : Icons.mic_none, size: 48),
          SizedBox(height: 8),
          Text(_recording ? 'Recording...' : 'Press to record a short message'),
          if (_uploading)
            Padding(
                padding: EdgeInsets.only(top: 8),
                child: CircularProgressIndicator())
        ],
      ),
      actions: [
        TextButton(
            onPressed:
                _uploading ? null : () => Navigator.of(context).pop(false),
            child: Text('Close')),
        ElevatedButton(
            onPressed: _uploading ? null : _toggleRecord,
            child: Text(_recording ? 'Stop' : 'Record')),
      ],
    );
  }
}
