import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/subscription.dart';

/// Subscription repository interface
abstract class ISubscriptionRepository {
  /// Get current subscription status
  Future<Either<Failure, Subscription?>> getCurrentSubscription(String userId);

  /// Get available subscription offerings
  Future<Either<Failure, List<SubscriptionOffering>>> getOfferings();

  /// Purchase a subscription
  Future<Either<Failure, Subscription>> purchaseSubscription(
    String offeringId,
  );

  /// Restore purchases
  Future<Either<Failure, Subscription?>> restorePurchases();

  /// Cancel subscription
  Future<Either<Failure, void>> cancelSubscription(String subscriptionId);

  /// Check if user is premium
  Future<Either<Failure, bool>> isPremium(String userId);

  /// Get subscription tier
  Future<Either<Failure, SubscriptionTier>> getSubscriptionTier(String userId);

  /// Check feature access
  Future<Either<Failure, bool>> hasFeatureAccess(
    String userId,
    SubscriptionFeature feature,
  );

  /// Stream subscription changes
  Stream<Subscription?> subscriptionChanges(String userId);

  /// Sync subscription status with backend
  Future<Either<Failure, void>> syncSubscriptionStatus(String userId);
}
