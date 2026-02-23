import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityAdsService {
  UnityAdsService._();

  static const String androidGameId = '6050838';
  static const String iosGameId = '6050839';
  static const String androidBannerPlacementId = 'Banner_Android';
  static const String iosBannerPlacementId = 'Banner_iOS';
  static const String androidRewardedPlacementId = 'Rewarded_Android';
  static const String iosRewardedPlacementId = 'Rewarded_iOS';
  static bool get testMode => kDebugMode;

  static Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    final TargetPlatform platform = defaultTargetPlatform;
    final String? gameId = switch (platform) {
      TargetPlatform.android => androidGameId,
      TargetPlatform.iOS => iosGameId,
      _ => null,
    };

    if (gameId == null) {
      return;
    }

    await UnityAds.init(
      gameId: gameId,
      testMode: testMode,
      onComplete: () {
        debugPrint(
          'Unity Ads initialized for gameId=$gameId (testMode=$testMode)',
        );
      },
      onFailed: (error, message) {
        debugPrint('Unity Ads init failed: $error - $message');
      },
    );
  }

  static String? bannerPlacementId() {
    if (kIsWeb) {
      return null;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => androidBannerPlacementId,
      TargetPlatform.iOS => iosBannerPlacementId,
      _ => null,
    };
  }

  static String? rewardedPlacementId() {
    if (kIsWeb) {
      return null;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => androidRewardedPlacementId,
      TargetPlatform.iOS => iosRewardedPlacementId,
      _ => null,
    };
  }

  static Future<bool> showRewardedUnlockAd({
    Duration timeout = const Duration(seconds: 45),
  }) async {
    final placementId = rewardedPlacementId();
    if (placementId == null) {
      return false;
    }

    final completer = Completer<bool>();

    try {
      await UnityAds.load(
        placementId: placementId,
        onComplete: (_) async {
          try {
            await UnityAds.showVideoAd(
              placementId: placementId,
              onComplete: (_) {
                if (!completer.isCompleted) {
                  completer.complete(true);
                }
              },
              onSkipped: (_) {
                if (!completer.isCompleted) {
                  completer.complete(false);
                }
              },
              onFailed: (_, error, message) {
                debugPrint(
                  'Unity rewarded show failed ($placementId): $error - $message',
                );
                if (!completer.isCompleted) {
                  completer.complete(false);
                }
              },
            );
          } catch (e) {
            debugPrint('Unity rewarded show exception: $e');
            if (!completer.isCompleted) {
              completer.complete(false);
            }
          }
        },
        onFailed: (_, error, message) {
          debugPrint(
            'Unity rewarded load failed ($placementId): $error - $message',
          );
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );
    } catch (e) {
      debugPrint('Unity rewarded load exception: $e');
      return false;
    }

    return Future.any<bool>([
      completer.future,
      Future<bool>.delayed(timeout, () => false),
    ]);
  }
}
