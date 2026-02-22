import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../theme/app_theme.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  static const routeName = '/legal';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('terms_title')),
        backgroundColor: Colors.transparent,
      ),
      body: NexoBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _LegalCard(
                title: l10n.t('terms_use'),
                body: l10n.t('terms_use_body'),
              ),
              const SizedBox(height: 12),
              _LegalCard(
                title: l10n.t('privacy_notice'),
                body: l10n.t('privacy_notice_body'),
              ),
              const SizedBox(height: 12),
              _LegalCard(
                title: l10n.t('contact'),
                body: l10n.t('contact_body'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalCard extends StatelessWidget {
  const _LegalCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
