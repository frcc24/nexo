class MoreGame {
  const MoreGame({
    required this.title,
    required this.androidPackage,
    required this.iosAppStoreId,
    required this.logoAssetPath,
  });

  final String title;
  final String androidPackage;
  final String? iosAppStoreId;
  final String logoAssetPath;

  Uri get androidStoreUri => Uri.parse(
    'https://play.google.com/store/apps/details?id=$androidPackage',
  );

  Uri? get iosStoreUri {
    if (iosAppStoreId == null || iosAppStoreId!.isEmpty) {
      return null;
    }
    return Uri.parse('https://apps.apple.com/app/id$iosAppStoreId');
  }
}
