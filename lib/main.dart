import 'package:flutter/material.dart';
import 'models/movie.dart';
import 'state/app_state.dart';
import 'screens/home_dashboard.dart';
import 'screens/search_filters.dart';
import 'screens/movie_details.dart';
import 'screens/user_profile.dart';
import 'screens/downloads_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlixNoir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0C10),
        primaryColor: const Color(0xFFE50914),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914),
          background: Color(0xFF0B0C10),
          surface: Color(0xFF1F2229),
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  void _navigateToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetails(
          state: _appState,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        late Widget activeScreen;
        switch (_appState.activeNavBarIndex) {
          case 0:
            activeScreen = HomeDashboard(
              state: _appState,
              onNavigateToDetails: _navigateToDetails,
            );
            break;
          case 1:
            activeScreen = SearchFilters(
              state: _appState,
              onNavigateToDetails: _navigateToDetails,
            );
            break;
          case 2:
            activeScreen = DownloadsManager(
              state: _appState,
              onNavigateToDetails: _navigateToDetails,
            );
            break;
          case 3:
            activeScreen = UserProfile(
              state: _appState,
            );
            break;
          default:
            activeScreen = HomeDashboard(
              state: _appState,
              onNavigateToDetails: _navigateToDetails,
            );
        }

        return activeScreen;
      },
    );
  }
}
