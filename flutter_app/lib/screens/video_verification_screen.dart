import 'package:flutter/material.dart';
import '../services/video_verification_service.dart';
import '../services/analytics_service.dart';

class VideoVerificationScreen extends StatefulWidget {
  const VideoVerificationScreen({super.key});

  @override
  State<VideoVerificationScreen> createState() =>
      _VideoVerificationScreenState();
}

class _VideoVerificationScreenState extends State<VideoVerificationScreen> {
  String? _jobId;
  String? _status;
  bool _loading = false;

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _status = null;
    });
    try {
      final res = await VideoVerificationService.startVerification();
      _jobId = res['jobId']?.toString();
      _status = res['status']?.toString() ?? 'started';
      AnalyticsService.track('id_verification_started', {'jobId': _jobId});
    } catch (e) {
      _status = 'error: $e';
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    if (_jobId == null) return;
    setState(() {
      _loading = true;
    });
    try {
      final res = await VideoVerificationService.status(_jobId!);
      _status = res['status']?.toString();
      AnalyticsService.track(
          'id_verification_polled', {'jobId': _jobId, 'status': _status});
    } catch (e) {
      _status = 'error: $e';
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _uploadSample() async {
    setState(() {
      _loading = true;
      _status = null;
    });
    try {
      // In a real app you'd pick a file; here we use a dummy path for tests
      final ok = await VideoVerificationService.uploadVideo(
          _jobId ?? '', 'test_assets/sample.mp4', 'sample.mp4');
      setState(() => _status = ok ? 'uploaded' : 'upload failed');
      AnalyticsService.track(
          'id_verification_submitted', {'jobId': _jobId, 'uploadOk': ok});
    } catch (e) {
      setState(() => _status = 'upload error: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
                onPressed: _loading ? null : _start,
                child: Text('Start Verification')),
            SizedBox(height: 12),
            ElevatedButton(
                onPressed: _jobId == null || _loading ? null : _refresh,
                child: Text('Refresh Status')),
            SizedBox(height: 12),
            ElevatedButton(
                onPressed: _loading ? null : _uploadSample,
                child: Text('Upload Sample Video')),
            SizedBox(height: 12),
            if (_jobId != null) Text('Job: $_jobId'),
            if (_status != null) Text('Status: $_status'),
            if (_loading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
