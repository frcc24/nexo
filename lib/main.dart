import 'package:flutter/material.dart';

import 'data/services/unity_ads_service.dart';
import 'presentation/controllers/world_map_controller.dart';
import 'presentation/screens/difficulty_screen.dart';
import 'presentation/screens/game_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/more_games_screen.dart';
import 'presentation/screens/world_map_screen.dart';
import 'presentation/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UnityAdsService.initialize();
  runApp(const NexoApp());
}

class NexoApp extends StatefulWidget {
  const NexoApp({super.key});

  @override
  State<NexoApp> createState() => _NexoAppState();
}

class _NexoAppState extends State<NexoApp> {
  final WorldMapController _worldMapController = WorldMapController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(),
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        DifficultyScreen.routeName: (_) => const DifficultyScreen(),
        MoreGamesScreen.routeName: (_) => const MoreGamesScreen(),
        WorldMapScreen.routeName: (_) =>
            WorldMapScreen(controller: _worldMapController),
      },
      onGenerateRoute: (settings) {
        if (settings.name == GameScreen.routeName) {
          final args = settings.arguments as GameRouteArgs;
          return MaterialPageRoute(builder: (_) => GameScreen(args: args));
        }
        return null;
      },
      initialRoute: HomeScreen.routeName,
    );
  }
}
