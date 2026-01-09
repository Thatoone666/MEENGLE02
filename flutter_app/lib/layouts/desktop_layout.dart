import 'package:flutter/material.dart';

class DesktopLayout extends StatelessWidget {
  final Widget primaryContent;
  final Widget? secondaryContent;
  final List<NavigationRailDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget? bottomBar;

  const DesktopLayout({
    super.key,
    required this.primaryContent,
    this.secondaryContent,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations,
            extended: MediaQuery.of(context).size.width > 600,
          ),
          Expanded(
            child: primaryContent,
          ),
          if (secondaryContent != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: secondaryContent!,
              ),
            ),
        ],
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}