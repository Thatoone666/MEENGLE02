import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:meengle_flutter/screens/swipe_screen.dart';
import 'package:meengle_flutter/screens/matches_list.dart';
import 'package:meengle_flutter/screens/profile_edit.dart';
import 'package:meengle_flutter/screens/location_checkin_discovery_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions = <Widget>[
    const SwipeScreen(),
    const MatchesListScreen(),
    const LocationCheckInDiscoveryScreen(),
    const ProfileEditScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: _buildGlassmorphicNavBar(),
    );
  }

  Widget _buildGlassmorphicNavBar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24.0),
        topRight: Radius.circular(24.0),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withAlpha(51), width: 1.0),
            ),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.swipe),
                label: 'Swipe',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Matches',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on),
                label: 'CheckIn',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.white.withAlpha(153),
            showUnselectedLabels: false,
            showSelectedLabels: false,
          ),
        ),
      ),
    );
  }
}
