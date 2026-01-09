import 'package:flutter/material.dart';
import 'package:meengle_flutter/services/api.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  MatchesScreenState createState() => MatchesScreenState();
}

class MatchesScreenState extends State<MatchesScreen> {
  List<Map<String, dynamic>> _matches = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final matches = await ApiService.getMatches();
      if (!mounted) return;
      setState(() {
        _matches = matches;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    }
    
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  Future<void> _navigateToChat(BuildContext context, Map<String, dynamic> match) async {
    // Capture navigation state before async operations
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      final me = await ApiService.getProfile();
      if (!mounted) return;

      final myId = me?['_id']?.toString();
      if (!mounted) return;

      if (myId != null) {
        navigator.pushNamed('/chat',
            arguments: {'userId': myId, 'match': match});
      } else {
        messenger.showSnackBar(
            const SnackBar(
                content: Text('Could not identify current user.')));
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Matches'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _matches.isEmpty
                  ? const Center(child: Text('No matches yet. Keep swiping!'))
                  : ListView.builder(
                      itemCount: _matches.length,
                      itemBuilder: (context, index) {
                        final match = _matches[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              ApiService.resolveAssetUrl(match['images'][0]),
                            ),
                          ),
                          title: Text(match['name']),
                          onTap: () {
                            _navigateToChat(context, match);
                          },
                        );
                      },
                    ),
    );
  }
}
