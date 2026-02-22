import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/more_game.dart';
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
        const SnackBar(content: Text('Não foi possível abrir a loja agora.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mais Jogos'),
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
                    const Text(
                      'Conheça este jogo e instale pela loja:',
                      style: TextStyle(
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
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'App Store em breve.',
                          style: TextStyle(color: AppTheme.textSecondary),
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
