import 'package:flutter/material.dart';
import '../widgets/find_me_button.dart';

/// Example of how to integrate Find Me button into main screen
/// 
/// The Find Me button should be placed in the AppBar of your main screen
/// as a small, discrete button at the top right

class MainScreenWithFindMe extends StatefulWidget {
  const MainScreenWithFindMe({Key? key}) : super(key: key);

  @override
  State<MainScreenWithFindMe> createState() => _MainScreenWithFindMeState();
}

class _MainScreenWithFindMeState extends State<MainScreenWithFindMe> {
  int _selectedIndex = 0;
  String? _userId = 'current_user_id'; // Get from auth

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meengle',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          // ? Add Find Me button here (discrete and at top right)
          FindMeButton(
            userId: _userId ?? 'user_id',
            onSuccess: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('? Location shared successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            onError: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('? Failed to share location'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const DiscoverScreen();
      case 1:
        return const MessagesScreen();
      case 2:
        return const MatchesScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const DiscoverScreen();
    }
  }
}

// Placeholder screens
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Discover Screen'),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Messages Screen'),
    );
  }
}

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Matches Screen'),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Screen'),
    );
  }
}
