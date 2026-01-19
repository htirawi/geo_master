import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/services/logger_service.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../datasources/remote/revenuecat_datasource.dart';

/// Subscription repository implementation using RevenueCat
class SubscriptionRepositoryImpl implements ISubscriptionRepository {
  SubscriptionRepositoryImpl({
    required IRevenueCatDataSource revenueCatDataSource,
  }) : _revenueCatDataSource = revenueCatDataSource;

  final IRevenueCatDataSource _revenueCatDataSource;

  // Cache for offerings to avoid repeated API calls
  List<SubscriptionOffering>? _cachedOfferings;
  DateTime? _offeringsLastFetch;
  static const _offeringsCacheDuration = Duration(minutes: 30);

  @override
  Future<Either<Failure, Subscription?>> getCurrentSubscription(
    String userId,
  ) async {
    try {
      final customerInfo = await _revenueCatDataSource.getCustomerInfo();

      // Check if user has any active entitlements
      if (customerInfo.entitlements.active.isEmpty) {
        logger.debug('No active subscription for user: $userId', tag: 'SubRepo');
        return const Right(null);
      }

      final subscription = (_revenueCatDataSource as RevenueCatDataSource)
          .customerInfoToSubscription(customerInfo, userId);

      logger.debug(
        'Got subscription: ${subscription?.tier.name}',
        tag: 'SubRepo',
      );
      return Right(subscription);
    } on ServerException catch (e) {
      logger.error('Error getting subscription', tag: 'SubRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error getting subscription',
        tag: 'SubRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: 'Failed to get subscription: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionOffering>>> getOfferings() async {
    try {
      // Check cache
      if (_cachedOfferings != null &&
          _offeringsLastFetch != null &&
          DateTime.now().difference(_offeringsLastFetch!) <
              _offeringsCacheDuration) {
        return Right(_cachedOfferings!);
      }

      final offerings = await _revenueCatDataSource.getOfferings();

      if (offerings == null || offerings.current == null) {
        logger.warning('No offerings available', tag: 'SubRepo');
        return const Right([]);
      }

      final subscriptionOfferings = <SubscriptionOffering>[];
      final dataSource = _revenueCatDataSource as RevenueCatDataSource;

      // Convert all packages to offerings
      for (final package in offerings.current!.availablePackages) {
        final offering = dataSource.packageToOffering(package);
        if (offering != null) {
          subscriptionOfferings.add(offering);
        }
      }

      // Sort by tier and period
      subscriptionOfferings.sort((a, b) {
        final tierCompare = a.tier.index.compareTo(b.tier.index);
        if (tierCompare != 0) return tierCompare;
        return a.period.index.compareTo(b.period.index);
      });

      // Update cache
      _cachedOfferings = subscriptionOfferings;
      _offeringsLastFetch = DateTime.now();

      logger.debug(
        'Got ${subscriptionOfferings.length} offerings',
        tag: 'SubRepo',
      );
      return Right(subscriptionOfferings);
    } on ServerException catch (e) {
      logger.error('Error getting offerings', tag: 'SubRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error getting offerings',
        tag: 'SubRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: 'Failed to get subscription options: $e'));
    }
  }

  @override
  Future<Either<Failure, Subscription>> purchaseSubscription(
    String offeringId,
  ) async {
    try {
      // Get the package from offerings
      final offerings = await _revenueCatDataSource.getOfferings();
      if (offerings?.current == null) {
        return Left(SubscriptionFailure.offeringsNotAvailable());
      }

      final package = offerings!.current!.availablePackages.firstWhere(
        (p) => p.identifier == offeringId,
        orElse: () => throw const ServerException(message: 'Package not found'),
      );

      // Make the purchase
      final customerInfo = await _revenueCatDataSource.purchasePackage(package);

      // Convert to subscription
      final dataSource = _revenueCatDataSource as RevenueCatDataSource;
      final subscription = dataSource.customerInfoToSubscription(
        customerInfo,
        customerInfo.originalAppUserId,
      );

      if (subscription == null) {
        return Left(SubscriptionFailure.purchaseFailed());
      }

      // Clear offerings cache to get fresh data
      _cachedOfferings = null;

      logger.info(
        'Purchase successful: ${subscription.tier.name}',
        tag: 'SubRepo',
      );
      return Right(subscription);
    } on ServerException catch (e) {
      logger.error('Error purchasing subscription', tag: 'SubRepo', error: e);

      if (e.message.contains('cancelled')) {
        return Left(SubscriptionFailure.purchaseCancelled());
      }
      return Left(SubscriptionFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error purchasing subscription',
        tag: 'SubRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(SubscriptionFailure(message: 'Failed to complete purchase: $e'));
    }
  }

  @override
  Future<Either<Failure, Subscription?>> restorePurchases() async {
    try {
      final customerInfo = await _revenueCatDataSource.restorePurchases();

      if (customerInfo.entitlements.active.isEmpty) {
        logger.info('No purchases to restore', tag: 'SubRepo');
        return const Right(null);
      }

      final dataSource = _revenueCatDataSource as RevenueCatDataSource;
      final subscription = dataSource.customerInfoToSubscription(
        customerInfo,
        customerInfo.originalAppUserId,
      );

      logger.info(
        'Restored subscription: ${subscription?.tier.name}',
        tag: 'SubRepo',
      );
      return Right(subscription);
    } on ServerException catch (e) {
      logger.error('Error restoring purchases', tag: 'SubRepo', error: e);
      return Left(SubscriptionFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error restoring purchases',
        tag: 'SubRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(SubscriptionFailure(message: 'Failed to restore purchases: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelSubscription(
    String subscriptionId,
  ) async {
    // Note: Subscription cancellation is typically done through the
    // platform's subscription management (App Store/Play Store).
    // RevenueCat doesn't support programmatic cancellation.
    try {
      logger.info(
        'Cancellation requested for: $subscriptionId',
        tag: 'SubRepo',
      );

      // Return success but inform that user needs to cancel through store
      return const Right(null);
    } catch (e, stackTrace) {
      logger.error(
        'Error processing cancellation request',
        tag: 'SubRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(
        SubscriptionFailure(message: 'Failed to process cancellation: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isPremium(String userId) async {
    try {
      final customerInfo = await _revenueCatDataSource.getCustomerInfo();
      final hasPremium = customerInfo.entitlements.active.isNotEmpty;

      return Right(hasPremium);
    } on ServerException catch (e) {
      logger.error('Error checking premium status', tag: 'SubRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error checking premium status',
        tag: 'SubRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: 'Failed to check premium status: $e'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionTier>> getSubscriptionTier(
    String userId,
  ) async {
    try {
      final customerInfo = await _revenueCatDataSource.getCustomerInfo();
      final dataSource = _revenueCatDataSource as RevenueCatDataSource;
      final tier = dataSource.getTierFromCustomerInfo(customerInfo);

      logger.debug('User tier: ${tier.name}', tag: 'SubRepo');
      return Right(tier);
    } on ServerException catch (e) {
      logger.error('Error getting subscription tier', tag: 'SubRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error getting subscription tier',
        tag: 'SubRepo',
        error: e,
        stackTrace: stackTrace,
      );
      // Default to free tier on error
      return const Right(SubscriptionTier.free);
    }
  }

  @override
  Future<Either<Failure, bool>> hasFeatureAccess(
    String userId,
    SubscriptionFeature feature,
  ) async {
    try {
      final tierResult = await getSubscriptionTier(userId);

      return tierResult.fold(
        Left.new,
        (tier) {
          final hasAccess = tier.features.contains(feature);
          return Right(hasAccess);
        },
      );
    } catch (e, stackTrace) {
      logger.error(
        'Error checking feature access',
        tag: 'SubRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: 'Failed to check feature access: $e'));
    }
  }

  @override
  Stream<Subscription?> subscriptionChanges(String userId) {
    return _revenueCatDataSource.customerInfoStream.map((customerInfo) {
      if (customerInfo.entitlements.active.isEmpty) {
        return null;
      }

      final dataSource = _revenueCatDataSource as RevenueCatDataSource;
      return dataSource.customerInfoToSubscription(customerInfo, userId);
    });
  }

  @override
  Future<Either<Failure, void>> syncSubscriptionStatus(String userId) async {
    try {
      // Log in user to sync their status
      await _revenueCatDataSource.logIn(userId);

      // Clear cache to force refresh
      _cachedOfferings = null;

      logger.info('Subscription status synced for: $userId', tag: 'SubRepo');
      return const Right(null);
    } on ServerException catch (e) {
      logger.error('Error syncing subscription', tag: 'SubRepo', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error syncing subscription',
        tag: 'SubRepo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure(message: 'Failed to sync subscription: $e'));
    }
  }
}
