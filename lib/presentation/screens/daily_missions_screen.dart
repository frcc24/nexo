import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../controllers/retention_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/nexo_button.dart';
import 'game_screen.dart';

class DailyMissionsScreen extends StatefulWidget {
  const DailyMissionsScreen({super.key, required this.retentionController});

  static const routeName = '/daily-missions';

  final RetentionController retentionController;

  @override
  State<DailyMissionsScreen> createState() => _DailyMissionsScreenState();
}

class _DailyMissionsScreenState extends State<DailyMissionsScreen> {
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final missions = widget.retentionController.dailyMissions;
    final completed = missions.where((m) => m.completed).length;
    final total = missions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('daily_missions')),
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
                      colors: [Color(0xFF0FA3FF), Color(0xFF53F0CC)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF19C4F6).withValues(alpha: 0.32),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.task_alt_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${l10n.t('daily_missions_progress')}: $completed/$total',
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: NexoButton(
                  label: l10n.t('daily_challenge'),
                  icon: Icons.bolt_outlined,
                  primary: false,
                  onPressed: _openDailyChallenge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
                  itemCount: missions.length,
                  itemBuilder: (context, index) {
                    final mission = missions[index];
                    return _MissionCard(mission: mission);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission});

  final DailyMission mission;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = mission.target <= 0
        ? 0.0
        : (mission.progress / mission.target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E3754), Color(0xFF252E48)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mission.completed
              ? const Color(0xFF53F0CC).withValues(alpha: 0.65)
              : Colors.white12,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
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
              color: Colors.black.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(
              mission.completed ? Icons.check_rounded : Icons.flag_outlined,
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
                  l10n.t(mission.titleKey),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${mission.progress}/${mission.target}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppTheme.surfaceSoft,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      mission.completed
                          ? const Color(0xFF53F0CC)
                          : const Color(0xFF31B2FF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            mission.completed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: mission.completed ? const Color(0xFF53F0CC) : Colors.white38,
          ),
        ],
      ),
    );
  }
}
