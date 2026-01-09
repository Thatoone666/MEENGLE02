import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';

class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({super.key});

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _matches = [];

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _loading = true);
    try {
      final matches = await APIService.getMatches();
      setState(() {
        _matches = matches;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Matches')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _loadMatches, child: const Text('Retry')),
                    ],
                  ),
                )
              : _matches.isEmpty
                  ? const Center(child: Text('No matches yet. Keep swiping!'))
                  : ListView.builder(
                      itemCount: _matches.length,
                      itemBuilder: (context, i) {
                        final user = _matches[i];
                        final imageUrl = (user['photos'] as List?)?.isNotEmpty == true
                            ? APIService.resolveAssetUrl((user['photos'] as List)[0])
                            : null;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                              child: imageUrl == null ? const Icon(Icons.person) : null,
                            ),
                            title: Text('${user['name'] ?? 'Unknown'}, ${user['age'] ?? '?'}'),
                            subtitle: Text(user['bio'] ?? 'No bio'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.pushNamed(context, '/chat', arguments: {
                              'matchId': user['_id'] ?? user['id'],
                              'matchName': user['name'] ?? 'Unknown',
                              'matchImage': imageUrl,
                            }),
                          ),
                        );
                      },
                    ),
    );
  }
}
