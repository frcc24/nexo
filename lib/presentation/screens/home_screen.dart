import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/nexo_button.dart';
import '../widgets/rule_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: NexoBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.menu),
                    color: AppTheme.surface,
                    onSelected: (value) {
                      if (value == 'settings') {
                        Navigator.pushNamed(context, '/settings');
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem<String>(
                        value: 'settings',
                        child: Text(l10n.t('settings')),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                NexoTitle(subtitle: l10n.t('subtitle')),
                const Spacer(),
                NexoButton(
                  label: l10n.t('play'),
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => Navigator.pushNamed(context, '/world-map'),
                ),
                const SizedBox(height: 14),
                NexoButton(
                  label: l10n.t('rules'),
                  icon: Icons.menu_book_rounded,
                  primary: false,
                  onPressed: () => showRulesModal(context),
                ),
                const SizedBox(height: 14),
                NexoButton(
                  label: l10n.t('more_games'),
                  icon: Icons.games_outlined,
                  primary: false,
                  onPressed: () => Navigator.pushNamed(context, '/more-games'),
                ),
                const SizedBox(height: 14),
                NexoButton(
                  label: l10n.t('terms_privacy'),
                  icon: Icons.privacy_tip_outlined,
                  primary: false,
                  onPressed: () => Navigator.pushNamed(context, '/legal'),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/difficulty'),
                  child: Text(l10n.t('quick_mode')),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
