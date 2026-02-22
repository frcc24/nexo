import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../controllers/locale_controller.dart';
import '../controllers/purchase_controller.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.localeController,
    required this.purchaseController,
  });

  static const routeName = '/settings';

  final LocaleController localeController;
  final PurchaseController purchaseController;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    widget.localeController.addListener(_onLocaleChanged);
    widget.purchaseController.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    widget.localeController.removeListener(_onLocaleChanged);
    widget.purchaseController.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentCode = widget.localeController.locale.languageCode;
    final purchase = widget.purchaseController;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('settings')),
        backgroundColor: Colors.transparent,
      ),
      body: NexoBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('remove_ads'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      purchase.hasRemovedAds
                          ? l10n.t('ads_removed_active')
                          : l10n.removeAdsFor(price: purchase.priceLabel),
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    if (purchase.lastError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l10n.t('purchase_error_short'),
                          style: const TextStyle(color: Color(0xFFFF8D93)),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed:
                                purchase.hasRemovedAds || purchase.isPurchasing
                                ? null
                                : () {
                                    purchase.buyRemoveAds();
                                  },
                            icon: const Icon(Icons.remove_circle_outline),
                            label: Text(
                              purchase.isPurchasing
                                  ? l10n.t('processing')
                                  : l10n.t('buy'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: purchase.isPurchasing
                                ? null
                                : () {
                                    purchase.restorePurchases();
                                  },
                            icon: const Icon(Icons.restore),
                            label: Text(l10n.t('restore_purchases')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('choose_language'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _LanguageOption(
                      selected: currentCode == 'pt',
                      title: l10n.t('language_pt'),
                      onTap: () =>
                          widget.localeController.setLocale(const Locale('pt')),
                    ),
                    _LanguageOption(
                      selected: currentCode == 'en',
                      title: l10n.t('language_en'),
                      onTap: () =>
                          widget.localeController.setLocale(const Locale('en')),
                    ),
                    _LanguageOption(
                      selected: currentCode == 'es',
                      title: l10n.t('language_es'),
                      onTap: () =>
                          widget.localeController.setLocale(const Locale('es')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.selected,
    required this.title,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected
                  ? AppTheme.brandPurpleLight
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
      ),
    );
  }
}
