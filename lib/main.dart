import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/notes_provider.dart';
import 'providers/timer_provider.dart';
import 'screens/timer_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/history_screen.dart';
import 'screens/notes_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: const StudyTrackerApp(),
    ),
  );
}

class StudyTrackerApp extends StatelessWidget {
  const StudyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cronômetro de Estudos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TimerScreen(),
    const StatsScreen(),
    const HistoryScreen(),
    const NotesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer), label: 'Cronômetro'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Estatísticas'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Histórico'),
          NavigationDestination(icon: Icon(Icons.sticky_note_2_outlined), label: 'Notas'),
        ],
      ),
    );
  }
}