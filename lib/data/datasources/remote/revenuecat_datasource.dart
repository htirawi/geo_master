import 'dart:async';
import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/services/logger_service.dart';
import '../../../domain/entities/subscription.dart';

/// RevenueCat data source interface
abstract class IRevenueCatDataSource {
  /// Initialize RevenueCat SDK
  Future<void> initialize({required String userId});

  /// Get current customer info
  Future<CustomerInfo> getCustomerInfo();

  /// Get available offerings
  Future<Offerings?> getOfferings();

  /// Purchase a package
  Future<CustomerInfo> purchasePackage(Package package);

  /// Restore purchases
  Future<CustomerInfo> restorePurchases();

  /// Log in user
  Future<CustomerInfo> logIn(String userId);

  /// Log out user
  Future<void> logOut();

  /// Stream customer info updates
  Stream<CustomerInfo> get customerInfoStream;

  /// Check if user has active entitlement
  bool hasActiveEntitlement(CustomerInfo customerInfo, String entitlementId);
}

/// RevenueCat data source implementation
class RevenueCatDataSource implements IRevenueCatDataSource {
  RevenueCatDataSource({
    required String apiKey,
  }) : _apiKey = apiKey;

  final String _apiKey;
  bool _isInitialized = false;

  /// Entitlement IDs matching RevenueCat dashboard
  static const String proEntitlement = 'pro';
  static const String premiumEntitlement = 'premium';
  static const String basicEntitlement = 'basic';

  /// Product IDs
  static const String proMonthlyId = 'geo_master_pro_monthly';
  static const String proYearlyId = 'geo_master_pro_yearly';
  static const String premiumMonthlyId = 'geo_master_premium_monthly';
  static const String premiumYearlyId = 'geo_master_premium_yearly';

  @override
  Future<void> initialize({required String userId}) async {
    if (_isInitialized) return;

    try {
      final configuration = PurchasesConfiguration(_apiKey);

      if (Platform.isIOS) {
        // iOS-specific configuration if needed
      } else if (Platform.isAndroid) {
        // Android-specific configuration if needed
      }

      await Purchases.configure(configuration);

      if (userId.isNotEmpty) {
        await Purchases.logIn(userId);
      }

      _isInitialized = true;
      logger.info('RevenueCat initialized', tag: 'RevenueCat');
    } catch (e, stackTrace) {
      logger.error(
        'Failed to initialize RevenueCat',
        tag: 'RevenueCat',
        error: e,
        stackTrace: stackTrace,
      );
      throw const ServerException(message: 'Failed to initialize purchases');
    }
  }

  @override
  Future<CustomerInfo> getCustomerInfo() async {
    if (!_isInitialized || _apiKey.isEmpty) {
      throw const ServerException(message: 'RevenueCat not configured');
    }

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      logger.debug('Got customer info', tag: 'RevenueCat');
      return customerInfo;
    } catch (e) {
      logger.error('Failed to get customer info', tag: 'RevenueCat', error: e);
      throw const ServerException(message: 'Failed to get subscription info');
    }
  }

  @override
  Future<Offerings?> getOfferings() async {
    if (!_isInitialized || _apiKey.isEmpty) {
      throw const ServerException(message: 'RevenueCat not configured');
    }

    try {
      final offerings = await Purchases.getOfferings();
      logger.debug(
        'Got ${offerings.all.length} offerings',
        tag: 'RevenueCat',
      );
      return offerings;
    } catch (e) {
      logger.error('Failed to get offerings', tag: 'RevenueCat', error: e);
      throw const ServerException(message: 'Failed to get subscription options');
    }
  }

  @override
  Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      logger.info(
        'Purchase completed: ${package.identifier}',
        tag: 'RevenueCat',
      );
      return customerInfo;
    } on PurchasesErrorCode catch (e) {
      logger.error('Purchase error', tag: 'RevenueCat');

      if (e == PurchasesErrorCode.purchaseCancelledError) {
        throw const ServerException(message: 'Purchase cancelled');
      } else if (e == PurchasesErrorCode.purchaseNotAllowedError) {
        throw const ServerException(message: 'Purchases not allowed');
      } else if (e == PurchasesErrorCode.paymentPendingError) {
        throw const ServerException(message: 'Payment is pending');
      } else {
        throw const ServerException(message: 'Purchase failed');
      }
    } catch (e) {
      logger.error('Unexpected purchase error', tag: 'RevenueCat', error: e);
      throw const ServerException(message: 'Failed to complete purchase');
    }
  }

  @override
  Future<CustomerInfo> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      logger.info('Purchases restored', tag: 'RevenueCat');
      return customerInfo;
    } catch (e) {
      logger.error('Failed to restore purchases', tag: 'RevenueCat', error: e);
      throw const ServerException(message: 'Failed to restore purchases');
    }
  }

  @override
  Future<CustomerInfo> logIn(String userId) async {
    try {
      final result = await Purchases.logIn(userId);
      logger.info('User logged in to RevenueCat: $userId', tag: 'RevenueCat');
      return result.customerInfo;
    } catch (e) {
      logger.error('Failed to log in user', tag: 'RevenueCat', error: e);
      throw const ServerException(message: 'Failed to sync user');
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await Purchases.logOut();
      logger.info('User logged out from RevenueCat', tag: 'RevenueCat');
    } catch (e) {
      logger.error('Failed to log out user', tag: 'RevenueCat', error: e);
      throw const ServerException(message: 'Failed to sign out');
    }
  }

  @override
  Stream<CustomerInfo> get customerInfoStream {
    // Return empty stream if not initialized (API key missing)
    if (!_isInitialized && _apiKey.isEmpty) {
      return const Stream.empty();
    }

    // Create a stream from the CustomerInfo listener
    // ignore: close_sinks - intentionally long-lived for subscription updates
    final controller = StreamController<CustomerInfo>.broadcast();

    void listener(CustomerInfo info) {
      controller.add(info);
    }

    Purchases.addCustomerInfoUpdateListener(listener);

    // Note: In a real app, you'd want to remove the listener when done
    // This is a simplified implementation
    return controller.stream;
  }

  @override
  bool hasActiveEntitlement(CustomerInfo customerInfo, String entitlementId) {
    return customerInfo.entitlements.active.containsKey(entitlementId);
  }

  /// Convert RevenueCat customer info to subscription tier
  SubscriptionTier getTierFromCustomerInfo(CustomerInfo customerInfo) {
    if (hasActiveEntitlement(customerInfo, premiumEntitlement)) {
      return SubscriptionTier.premium;
    } else if (hasActiveEntitlement(customerInfo, proEntitlement)) {
      return SubscriptionTier.pro;
    } else if (hasActiveEntitlement(customerInfo, basicEntitlement)) {
      return SubscriptionTier.basic;
    }
    return SubscriptionTier.free;
  }

  /// Convert RevenueCat package to subscription offering
  SubscriptionOffering? packageToOffering(Package package) {
    try {
      final product = package.storeProduct;
      final tier = _getTierFromProductId(product.identifier);
      final period = _getPeriodFromPackageType(package.packageType);

      return SubscriptionOffering(
        id: package.identifier,
        productId: product.identifier,
        tier: tier,
        title: product.title,
        description: product.description,
        price: product.price,
        priceString: product.priceString,
        currencyCode: product.currencyCode,
        period: period,
        hasFreeTrial: product.introductoryPrice != null,
        freeTrialDays: _getTrialDays(product),
      );
    } catch (e) {
      logger.error('Failed to convert package', tag: 'RevenueCat', error: e);
      return null;
    }
  }

  SubscriptionTier _getTierFromProductId(String productId) {
    if (productId.contains('premium')) {
      return SubscriptionTier.premium;
    } else if (productId.contains('pro')) {
      return SubscriptionTier.pro;
    } else if (productId.contains('basic')) {
      return SubscriptionTier.basic;
    }
    return SubscriptionTier.free;
  }

  SubscriptionPeriod _getPeriodFromPackageType(PackageType type) {
    switch (type) {
      case PackageType.weekly:
        return SubscriptionPeriod.weekly;
      case PackageType.monthly:
        return SubscriptionPeriod.monthly;
      case PackageType.annual:
        return SubscriptionPeriod.yearly;
      default:
        return SubscriptionPeriod.monthly;
    }
  }

  int? _getTrialDays(StoreProduct product) {
    final intro = product.introductoryPrice;
    if (intro == null) return null;

    // Parse trial period from intro pricing
    // RevenueCat provides this in various formats depending on platform
    if (intro.periodUnit == PeriodUnit.day) {
      return intro.periodNumberOfUnits;
    } else if (intro.periodUnit == PeriodUnit.week) {
      return intro.periodNumberOfUnits * 7;
    }
    return null;
  }

  /// Convert customer info to subscription entity
  Subscription? customerInfoToSubscription(
    CustomerInfo customerInfo,
    String userId,
  ) {
    final tier = getTierFromCustomerInfo(customerInfo);

    if (tier == SubscriptionTier.free) {
      return null;
    }

    // Get the active entitlement info
    EntitlementInfo? activeEntitlement;
    if (customerInfo.entitlements.active.isNotEmpty) {
      activeEntitlement = customerInfo.entitlements.active.values.first;
    }

    // Parse dates from string (RevenueCat returns ISO8601 strings)
    DateTime? startDate;
    DateTime? expirationDate;

    final originalPurchaseDateStr = activeEntitlement?.originalPurchaseDate;
    if (originalPurchaseDateStr != null) {
      startDate = DateTime.tryParse(originalPurchaseDateStr);
    }
    final expirationDateStr = activeEntitlement?.expirationDate;
    if (expirationDateStr != null) {
      expirationDate = DateTime.tryParse(expirationDateStr);
    }

    return Subscription(
      id: activeEntitlement?.identifier ?? 'sub_$userId',
      userId: userId,
      tier: tier,
      status: _getStatusFromEntitlement(activeEntitlement),
      startDate: startDate ?? DateTime.now(),
      expirationDate: expirationDate,
      productId: activeEntitlement?.productIdentifier,
      platform: Platform.isIOS ? 'ios' : 'android',
      willRenew: activeEntitlement?.willRenew ?? false,
    );
  }

  SubscriptionStatus _getStatusFromEntitlement(EntitlementInfo? entitlement) {
    if (entitlement == null) return SubscriptionStatus.expired;

    if (entitlement.isActive) {
      if (entitlement.periodType == PeriodType.trial) {
        return SubscriptionStatus.trial;
      }
      return SubscriptionStatus.active;
    }

    if (entitlement.unsubscribeDetectedAt != null) {
      return SubscriptionStatus.cancelled;
    }

    return SubscriptionStatus.expired;
  }
}
