import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseController extends ChangeNotifier {
  PurchaseController({InAppPurchase? inAppPurchase})
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  static const String _removeAdsEntitlementKey = 'remove_ads_entitlement';

  // Configure these IDs exactly as created in Play Console / App Store Connect.
  static const String androidRemoveAdsProductId = 'remove_ads';
  static const String iosRemoveAdsProductId = 'remove_ads';

  final InAppPurchase _inAppPurchase;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool _initialized = false;
  bool _storeAvailable = false;
  bool _isLoadingProducts = false;
  bool _isPurchasing = false;
  bool _hasRemovedAds = false;
  String? _lastError;
  ProductDetails? _removeAdsProduct;

  bool get initialized => _initialized;
  bool get storeAvailable => _storeAvailable;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isPurchasing => _isPurchasing;
  bool get hasRemovedAds => _hasRemovedAds;
  String? get lastError => _lastError;
  ProductDetails? get removeAdsProduct => _removeAdsProduct;
  String get priceLabel => _removeAdsProduct?.price ?? 'R\$ 5,00';

  Set<String> get _allProductIds {
    final ids = <String>[];
    ids.add(androidRemoveAdsProductId);
    if (iosRemoveAdsProductId != androidRemoveAdsProductId) {
      ids.add(iosRemoveAdsProductId);
    }
    return ids.toSet();
  }

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _hasRemovedAds = prefs.getBool(_removeAdsEntitlementKey) ?? false;

    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (Object error) {
        _lastError = error.toString();
        notifyListeners();
      },
    );

    await _refreshProducts();

    _initialized = true;
    notifyListeners();
  }

  Future<void> _refreshProducts() async {
    _isLoadingProducts = true;
    _lastError = null;
    notifyListeners();

    _storeAvailable = await _inAppPurchase.isAvailable();
    if (!_storeAvailable) {
      _isLoadingProducts = false;
      _lastError = 'store_unavailable';
      notifyListeners();
      return;
    }

    final response = await _inAppPurchase.queryProductDetails(_allProductIds);
    if (response.error != null) {
      _isLoadingProducts = false;
      _lastError = response.error!.message;
      notifyListeners();
      return;
    }

    _removeAdsProduct = _selectProduct(response.productDetails);
    _isLoadingProducts = false;
    notifyListeners();
  }

  ProductDetails? _selectProduct(List<ProductDetails> products) {
    if (products.isEmpty) {
      return null;
    }

    final platformId = switch (defaultTargetPlatform) {
      TargetPlatform.android => androidRemoveAdsProductId,
      TargetPlatform.iOS => iosRemoveAdsProductId,
      _ => androidRemoveAdsProductId,
    };

    for (final product in products) {
      if (product.id == platformId) {
        return product;
      }
    }

    for (final product in products) {
      if (_allProductIds.contains(product.id)) {
        return product;
      }
    }
    return null;
  }

  Future<bool> buyRemoveAds() async {
    _lastError = null;

    if (!_storeAvailable || _removeAdsProduct == null) {
      await _refreshProducts();
    }

    if (!_storeAvailable || _removeAdsProduct == null) {
      _lastError = 'product_unavailable';
      notifyListeners();
      return false;
    }

    _isPurchasing = true;
    notifyListeners();

    final purchaseParam = PurchaseParam(productDetails: _removeAdsProduct!);
    final started = await _inAppPurchase.buyNonConsumable(
      purchaseParam: purchaseParam,
    );

    if (!started) {
      _isPurchasing = false;
      _lastError = 'purchase_not_started';
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<void> restorePurchases() async {
    _lastError = null;
    notifyListeners();
    await _inAppPurchase.restorePurchases();
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      final matchesProduct = _allProductIds.contains(purchase.productID);

      if (purchase.status == PurchaseStatus.pending) {
        _isPurchasing = true;
        notifyListeners();
      }

      if (purchase.status == PurchaseStatus.error) {
        _isPurchasing = false;
        _lastError = purchase.error?.message ?? 'purchase_error';
        notifyListeners();
      }

      if ((purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) &&
          matchesProduct) {
        await _setRemoveAdsEntitlement(true);
        _isPurchasing = false;
      }

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }

    notifyListeners();
  }

  Future<void> _setRemoveAdsEntitlement(bool value) async {
    _hasRemovedAds = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_removeAdsEntitlementKey, value);
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
