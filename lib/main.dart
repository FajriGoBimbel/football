import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/team_selection_screen.dart';
import 'screens/game_screen.dart';
import 'screens/result_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const FootballMiniGame());
}

class FootballMiniGame extends StatelessWidget {
  const FootballMiniGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Mini Game',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/team-selection': (context) => const TeamSelectionScreen(),
        '/game': (context) => const GameScreen(),
        '/result': (context) => const ResultScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
