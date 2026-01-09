import 'package:flutter/material.dart';
import '../services/api.dart';

class MatchDetailScreen extends StatefulWidget {
  const MatchDetailScreen({super.key});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  Map<String, dynamic>? user;
  bool _loading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) user = args;
  }

  Future<void> _like() async {
    if (user == null || user!['id'] == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ok = await ApiService.likeUser(user!['id'].toString(), 'regular');
      if (ok && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Liked')));
      } else {
        setState(() => _error = 'Failed to like');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user?['name'] ?? 'Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 8),
            ],
            Text('Name: ${user?['name'] ?? '-'}',
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            if ((user?['images'] ?? []).isNotEmpty) ...[
              Image.network(ApiService.resolveAssetUrl(user?['images'][0]),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => SizedBox.shrink()),
              SizedBox(height: 8),
            ],
            Text('Age: ${user?['age'] ?? '-'}'),
            SizedBox(height: 8),
            Text('Bio: ${user?['bio'] ?? ''}'),
            SizedBox(height: 16),
            ElevatedButton(
                onPressed: _loading ? null : _like,
                child: _loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Like')),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                // fetch current user id
                try {
                  final me = await ApiService.getProfile();
                  final myId = me?['id']?.toString() ?? me?['_id']?.toString();
                  if (myId == null) {
                    setState(
                        () => _error = 'Unable to determine current user id');
                    return;
                  }
                  if (mounted) {
                    navigator.pushNamed('/chat',
                        arguments: {'userId': myId, 'match': user});
                  }
                } catch (e) {
                  setState(() => _error = e.toString());
                }
              },
              child: Text('Chat'),
            )
          ],
        ),
      ),
    );
  }
}
