import 'package:flutter/material.dart';

import '../../domain/entities/cell_data.dart';
import '../../domain/entities/level.dart';
import '../../localization/app_localizations.dart';
import '../theme/app_theme.dart';

Future<void> showRulesModal(
  BuildContext context, {
  LevelData? level,
  String? customTitle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RulesSheet(level: level, customTitle: customTitle),
  );
}

class _RulesSheet extends StatelessWidget {
  const _RulesSheet({this.level, this.customTitle});

  final LevelData? level;
  final String? customTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Text(
                customTitle ?? l10n.t('how_to_play'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _RuleSection(
              title: l10n.t('objective'),
              body: l10n.t('objective_body'),
            ),
            _RuleSection(
              title: l10n.t('rule_same_color'),
              body: l10n.t('rule_same_color_body'),
              example: const _RuleExample(
                left: _BoxData(value: 2, color: CellColor.blue),
                right: _BoxData(value: 3, color: CellColor.blue),
                isValid: true,
              ),
            ),
            _RuleSection(
              title: l10n.t('rule_diff_color'),
              body: l10n.t('rule_diff_color_body'),
              example: const _RuleExample(
                left: _BoxData(value: 3, color: CellColor.blue),
                right: _BoxData(value: 3, color: CellColor.red),
                isValid: true,
              ),
            ),
            _RuleSection(
              title: l10n.t('invalid_move'),
              body: l10n.t('invalid_move_body'),
              example: const _RuleExample(
                left: _BoxData(value: 2, color: CellColor.red),
                right: _BoxData(value: 4, color: CellColor.blue),
                isValid: false,
              ),
            ),
            if (level != null &&
                level!.mechanics.contains(LevelMechanic.anchors))
              _RuleSection(
                title: l10n.t('rule_anchors_title'),
                body: l10n.t('rule_anchors_body'),
              ),
            if (level != null &&
                level!.mechanics.contains(LevelMechanic.portals))
              _RuleSection(
                title: l10n.t('rule_portals_title'),
                body: l10n.t('rule_portals_body'),
              ),
            if (level != null &&
                level!.mechanics.contains(LevelMechanic.arrows))
              _RuleSection(
                title: l10n.t('rule_arrows_title'),
                body: l10n.t('rule_arrows_body'),
              ),
          ],
        ),
      ),
    );
  }
}

class _RuleSection extends StatelessWidget {
  const _RuleSection({required this.title, required this.body, this.example});

  final String title;
  final String body;
  final Widget? example;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF38E0FF),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(color: AppTheme.textSecondary)),
            if (example != null) ...[const SizedBox(height: 12), example!],
          ],
        ),
      ),
    );
  }
}

class _BoxData {
  const _BoxData({required this.value, required this.color});

  final int value;
  final CellColor color;
}

class _RuleExample extends StatelessWidget {
  const _RuleExample({
    required this.left,
    required this.right,
    required this.isValid,
  });

  final _BoxData left;
  final _BoxData right;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ruleBox(left),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, color: Colors.white70),
        ),
        _ruleBox(right),
        const SizedBox(width: 10),
        Icon(
          isValid ? Icons.check : Icons.close,
          color: isValid ? const Color(0xFF46E07F) : const Color(0xFFFF656B),
        ),
      ],
    );
  }

  Widget _ruleBox(_BoxData data) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: data.color.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          '${data.value}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
