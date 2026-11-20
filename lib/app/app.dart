import 'package:flutter/material.dart';

import '../features/courses/courses_screen.dart';
import '../features/home/home_screen.dart';
import '../features/labs/labs_screen.dart';
import '../features/projects/projects_screen.dart';
import '../features/tools/progress_screen.dart';
import '../features/tools/tools_screen.dart';

/// Racine de l'application : navigation entre les 6 espaces principaux.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      const CoursesScreen(),
      const LabsScreen(),
      const ProjectsScreen(),
      const ToolsScreen(),
      const ProgressScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Cours',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science),
            label: 'Lab',
          ),
          NavigationDestination(
            icon: Icon(Icons.rocket_launch_outlined),
            selectedIcon: Icon(Icons.rocket_launch),
            label: 'Projets',
          ),
          NavigationDestination(
            icon: Icon(Icons.handyman_outlined),
            selectedIcon: Icon(Icons.handyman),
            label: 'Outils',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Aide à la navigation : pousse une page avec transition douce.
Future<T?> pushPage<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push(MaterialPageRoute<T>(builder: (_) => page));
}
