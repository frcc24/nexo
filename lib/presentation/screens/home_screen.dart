import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../controllers/retention_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/nexo_button.dart';
import '../widgets/rule_modal.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.retentionController});

  static const routeName = '/';

  final RetentionController retentionController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.retentionController.addListener(_onRetentionUpdated);
  }

  @override
  void dispose() {
    widget.retentionController.removeListener(_onRetentionUpdated);
    super.dispose();
  }

  void _onRetentionUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  void _openDailyChallenge() {
    final level = widget.retentionController.buildDailyChallengeLevel();
    Navigator.pushNamed(
      context,
      GameScreen.routeName,
      arguments: GameRouteArgs.dailyChallenge(level: level),
    );
  }

  Future<void> _showMissions() async {
    final l10n = context.l10n;
    final missions = widget.retentionController.dailyMissions;
    final bestScore = widget.retentionController.dailyBestScore;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(l10n.t('daily_missions')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final mission in missions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${mission.completed ? '✅' : '▫️'} ${l10n.t(mission.titleKey)} '
                  '(${mission.progress}/${mission.target})',
                ),
              ),
            if (bestScore != null) ...[
              const SizedBox(height: 8),
              Text('${l10n.t('best_score_today')}: $bestScore'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.t('back')),
          ),
        ],
      ),
    );
  }

  Future<void> _showAchievements() async {
    final l10n = context.l10n;
    final achievements = widget.retentionController.achievements;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(l10n.t('achievements')),
        content: SizedBox(
          width: 360,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final ach in achievements)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '${ach.unlocked ? '🏆' : '🔒'} ${l10n.t(ach.titleKey)}\n'
                    '${l10n.t(ach.descKey)}',
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.t('back')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final retention = widget.retentionController;

    return Scaffold(
      body: NexoBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/settings'),
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    NexoTitle(subtitle: l10n.t('subtitle')),
                    const SizedBox(height: 26),
                    NexoButton(
                      label: l10n.t('play'),
                      icon: Icons.play_arrow_rounded,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/world-map'),
                    ),
                    const SizedBox(height: 14),
                    NexoButton(
                      label: l10n.t('daily_challenge'),
                      icon: Icons.bolt_outlined,
                      primary: false,
                      onPressed: _openDailyChallenge,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: NexoButton(
                            label: l10n.t('daily_missions'),
                            icon: Icons.task_alt_outlined,
                            primary: false,
                            onPressed: _showMissions,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: NexoButton(
                            label:
                                '${l10n.t('achievements')} '
                                '(${retention.unlockedAchievementsCount}/${retention.totalAchievementsCount})',
                            icon: Icons.workspace_premium_outlined,
                            primary: false,
                            onPressed: _showAchievements,
                          ),
                        ),
                      ],
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
                      onPressed: () =>
                          Navigator.pushNamed(context, '/more-games'),
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
                      onPressed: () =>
                          Navigator.pushNamed(context, '/difficulty'),
                      child: Text(l10n.t('quick_mode')),
                    ),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
