import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/more_game.dart';
import '../../localization/app_localizations.dart';
import '../theme/app_theme.dart';

const List<MoreGame> moreGamesCatalog = <MoreGame>[
  MoreGame(
    title: 'Shot Game',
    androidPackage: 'br.com.frcc24.shotgame',
    iosAppStoreId: null,
    logoAssetPath: 'assets/shot_logo.png',
  ),
  MoreGame(
    title: 'Destiny Dice',
    androidPackage: 'br.com.frcc24.destinydice',
    iosAppStoreId: null,
    logoAssetPath: 'assets/destiny_logo.png',
  ),
  MoreGame(
    title: 'Amigos dos 2',
    androidPackage: 'br.com.frcc24.amigosdos2',
    iosAppStoreId: null,
    logoAssetPath: 'assets/amigos_logo.png',
  ),
];

class MoreGamesScreen extends StatelessWidget {
  const MoreGamesScreen({super.key});

  static const String routeName = '/more-games';

  Future<void> _openStore(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.t('store_open_error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('more_games')),
        backgroundColor: Colors.transparent,
      ),
      body: NexoBackground(
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemBuilder: (context, index) {
              final game = moreGamesCatalog[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            game.logoAssetPath,
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            game.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.t('more_games_subtitle'),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _openStore(context, game.androidStoreUri),
                            icon: const Icon(Icons.shop_2_outlined),
                            label: const Text('Google Play'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: game.iosStoreUri == null
                                ? null
                                : () => _openStore(context, game.iosStoreUri!),
                            icon: const Icon(Icons.apple),
                            label: const Text('App Store'),
                          ),
                        ),
                      ],
                    ),
                    if (game.iosStoreUri == null)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          l10n.t('app_store_soon'),
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemCount: moreGamesCatalog.length,
          ),
        ),
      ),
    );
  }
}
