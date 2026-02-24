import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/services/unity_ads_service.dart';
import 'localization/app_localizations.dart';
import 'presentation/controllers/locale_controller.dart';
import 'presentation/controllers/purchase_controller.dart';
import 'presentation/controllers/retention_controller.dart';
import 'presentation/controllers/world_map_controller.dart';
import 'presentation/screens/difficulty_screen.dart';
import 'presentation/screens/game_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/legal_screen.dart';
import 'presentation/screens/more_games_screen.dart';
import 'presentation/screens/settings_screen.dart';
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
  final LocaleController _localeController = LocaleController();
  final PurchaseController _purchaseController = PurchaseController();
  final RetentionController _retentionController = RetentionController();

  @override
  void initState() {
    super.initState();
    _localeController.addListener(_onLocaleChanged);
    _localeController.init();
    _purchaseController.init();
    _retentionController.init();
  }

  @override
  void dispose() {
    _localeController.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(),
      locale: _localeController.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale == null) {
          return const Locale('en');
        }
        for (final locale in supportedLocales) {
          if (locale.languageCode == deviceLocale.languageCode) {
            return locale;
          }
        }
        return const Locale('en');
      },
      routes: {
        HomeScreen.routeName: (_) =>
            HomeScreen(retentionController: _retentionController),
        DifficultyScreen.routeName: (_) => const DifficultyScreen(),
        LegalScreen.routeName: (_) => const LegalScreen(),
        MoreGamesScreen.routeName: (_) => const MoreGamesScreen(),
        SettingsScreen.routeName: (_) => SettingsScreen(
          localeController: _localeController,
          purchaseController: _purchaseController,
          worldMapController: _worldMapController,
        ),
        WorldMapScreen.routeName: (_) =>
            WorldMapScreen(controller: _worldMapController),
      },
      onGenerateRoute: (settings) {
        if (settings.name == GameScreen.routeName) {
          final args = settings.arguments as GameRouteArgs;
          return MaterialPageRoute(
            builder: (_) => GameScreen(
              args: args,
              purchaseController: _purchaseController,
              retentionController: _retentionController,
            ),
          );
        }
        return null;
      },
      initialRoute: HomeScreen.routeName,
    );
  }
}
