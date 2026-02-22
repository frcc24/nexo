import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityAdsService {
  UnityAdsService._();

  static const String androidGameId = '6050838';
  static const String iosGameId = '6050839';
  static const String androidBannerPlacementId = 'Banner_Android';
  static const String iosBannerPlacementId = 'Banner_iOS';
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
}
