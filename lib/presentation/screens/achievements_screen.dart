import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../controllers/retention_controller.dart';
import '../theme/app_theme.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key, required this.retentionController});

  static const routeName = '/achievements';

  final RetentionController retentionController;

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<AchievementCategory> _tabs = const [
    AchievementCategory.progress,
    AchievementCategory.mastery,
    AchievementCategory.daily,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    widget.retentionController.addListener(_onRetentionUpdated);
  }

  @override
  void dispose() {
    widget.retentionController.removeListener(_onRetentionUpdated);
    _tabController.dispose();
    super.dispose();
  }

  void _onRetentionUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final achievements = widget.retentionController.achievements;
    final unlocked = achievements.where((a) => a.unlocked).length;
    final total = achievements.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('achievements')),
        backgroundColor: Colors.transparent,
      ),
      body: NexoBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF742EFF), Color(0xFF31B2FF)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6F34FF).withValues(alpha: 0.36),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${l10n.t('achievements_progress')}: $unlocked/$total',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFA726), Color(0xFFFFD54F)],
                      ),
                    ),
                    dividerColor: Colors.transparent,
                    labelColor: Colors.black87,
                    unselectedLabelColor: AppTheme.textSecondary,
                    tabs: [
                      Tab(text: l10n.t('ach_category_progress')),
                      Tab(text: l10n.t('ach_category_mastery')),
                      Tab(text: l10n.t('ach_category_daily')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabs.map((category) {
                    final list = achievements
                        .where((a) => a.category == category)
                        .toList();
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final achievement = list[index];
                        return _AchievementCard(achievement: achievement);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});

  final AchievementProgress achievement;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = _paletteForCategory(achievement.category);
    final icon = _iconFor(achievement.iconKey);
    final locked = !achievement.unlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: locked
              ? [const Color(0xFF2B3145), const Color(0xFF23293B)]
              : palette,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: locked ? Colors.white12 : Colors.white.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: locked
                ? Colors.black.withValues(alpha: 0.2)
                : palette.first.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: locked ? 0.22 : 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              locked ? Icons.lock_outline_rounded : icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t(achievement.titleKey),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.t(achievement.descKey),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            achievement.unlocked
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: achievement.unlocked
                ? const Color(0xFF53F0CC)
                : Colors.white38,
          ),
        ],
      ),
    );
  }

  List<Color> _paletteForCategory(AchievementCategory category) {
    return switch (category) {
      AchievementCategory.progress => [
        const Color(0xFF7D3BFF),
        const Color(0xFFB04AFF),
      ],
      AchievementCategory.mastery => [
        const Color(0xFF1565FF),
        const Color(0xFF2EC7FF),
      ],
      AchievementCategory.daily => [
        const Color(0xFFFF7A18),
        const Color(0xFFFFC447),
      ],
    };
  }

  IconData _iconFor(String key) {
    return switch (key) {
      'rocket' => Icons.rocket_launch_outlined,
      'target' => Icons.gps_fixed_rounded,
      'crown' => Icons.workspace_premium_rounded,
      'medal' => Icons.military_tech_rounded,
      'trophy' => Icons.emoji_events_rounded,
      'diamond' => Icons.diamond_outlined,
      'spark' => Icons.flash_on_rounded,
      'stars' => Icons.auto_awesome_rounded,
      'gem' => Icons.blur_on_rounded,
      'galaxy' => Icons.nights_stay_rounded,
      'shield' => Icons.shield_outlined,
      'brain' => Icons.psychology_alt_outlined,
      'focus' => Icons.center_focus_strong_rounded,
      'mastermind' => Icons.psychology_rounded,
      'calendar' => Icons.calendar_month_rounded,
      'calendar_fire' => Icons.local_fire_department_outlined,
      'calendar_star' => Icons.star_outline_rounded,
      'calendar_bolt' => Icons.bolt_rounded,
      'calendar_crown' => Icons.workspace_premium_outlined,
      _ => Icons.emoji_events_outlined,
    };
  }
}
