import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import '../../data/services/unity_ads_service.dart';

class UnityGameBanner extends StatefulWidget {
  const UnityGameBanner({super.key});

  @override
  State<UnityGameBanner> createState() => _UnityGameBannerState();
}

class _UnityGameBannerState extends State<UnityGameBanner> {
  bool _showBanner = true;
  int _reloadToken = 0;
  Timer? _retryTimer;

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 20), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _reloadToken++;
        _showBanner = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final placementId = UnityAdsService.bannerPlacementId();
    if (!_showBanner || placementId == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Center(
        child: KeyedSubtree(
          key: ValueKey(_reloadToken),
          child: UnityBannerAd(
            placementId: placementId,
            size: BannerSize.standard,
            onFailed: (placementId, error, message) {
              debugPrint(
                'Unity banner failed ($placementId): $error - $message',
              );
              if (!mounted) {
                return;
              }
              setState(() {
                _showBanner = false;
              });
              _scheduleRetry();
            },
            onLoad: (_) {
              _retryTimer?.cancel();
            },
          ),
        ),
      ),
    );
  }
}
