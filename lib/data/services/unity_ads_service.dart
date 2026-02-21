import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityAdsService {
  UnityAdsService._();

  static const String androidGameId = '6050837';
  static const String iosGameId = '6050836';

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
      testMode: false,
      onComplete: () {
        debugPrint('Unity Ads initialized for gameId=$gameId');
      },
      onFailed: (error, message) {
        debugPrint('Unity Ads init failed: $error - $message');
      },
    );
  }
}
