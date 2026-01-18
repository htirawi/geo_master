import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/service_locator.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import 'auth_provider.dart';

/// Subscription state
sealed class SubscriptionState {
  const SubscriptionState();

  bool get isLoading => this is SubscriptionLoading;
  bool get hasSubscription => this is SubscriptionLoaded && (this as SubscriptionLoaded).subscription != null;
  bool get isPremium => subscription?.isPremium ?? false;

  Subscription? get subscription {
    if (this is SubscriptionLoaded) {
      return (this as SubscriptionLoaded).subscription;
    }
    return null;
  }

  SubscriptionTier get tier {
    return subscription?.tier ?? SubscriptionTier.free;
  }
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class SubscriptionLoaded extends SubscriptionState {
  const SubscriptionLoaded({
    this.subscription,
    required this.offerings,
    required this.tier,
  });

  @override
  final Subscription? subscription;
  final List<SubscriptionOffering> offerings;
  @override
  final SubscriptionTier tier;
}

class SubscriptionPurchasing extends SubscriptionState {
  const SubscriptionPurchasing(this.offeringId);

  final String offeringId;
}

class SubscriptionError extends SubscriptionState {
  const SubscriptionError(this.failure);

  final Failure failure;
}

/// Subscription state notifier
class SubscriptionNotifier extends StateNotifier<AsyncValue<SubscriptionState>> {
  SubscriptionNotifier(this._subscriptionRepository)
      : super(const AsyncValue.data(SubscriptionInitial()));

  final ISubscriptionRepository _subscriptionRepository;
  StreamSubscription<Subscription?>? _subscriptionChanges;
  Subscription? _currentSubscription;
  List<SubscriptionOffering> _offerings = [];
  SubscriptionTier _currentTier = SubscriptionTier.free;

  /// Initialize subscription - load current status and offerings
  Future<void> initialize(String userId) async {
    state = const AsyncValue.loading();

    // Get current subscription
    final subscriptionResult = await _subscriptionRepository.getCurrentSubscription(userId);
    subscriptionResult.fold(
      (failure) {},
      (subscription) {
        _currentSubscription = subscription;
        _currentTier = subscription?.tier ?? SubscriptionTier.free;
      },
    );

    // Get offerings
    final offeringsResult = await _subscriptionRepository.getOfferings();
    offeringsResult.fold(
      (failure) {},
      (offerings) => _offerings = offerings,
    );

    // Listen for subscription changes
    _subscriptionChanges?.cancel();
    _subscriptionChanges = _subscriptionRepository.subscriptionChanges(userId).listen(
      (subscription) {
        _currentSubscription = subscription;
        _currentTier = subscription?.tier ?? SubscriptionTier.free;
        _updateState();
      },
    );

    _updateState();
  }

  void _updateState() {
    state = AsyncValue.data(SubscriptionLoaded(
      subscription: _currentSubscription,
      offerings: _offerings,
      tier: _currentTier,
    ));
  }

  /// Purchase a subscription
  Future<bool> purchaseSubscription(String offeringId) async {
    state = AsyncValue.data(SubscriptionPurchasing(offeringId));

    final result = await _subscriptionRepository.purchaseSubscription(offeringId);

    return result.fold(
      (failure) {
        state = AsyncValue.data(SubscriptionError(failure));
        return false;
      },
      (subscription) {
        _currentSubscription = subscription;
        _currentTier = subscription.tier;
        _updateState();
        return true;
      },
    );
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    state = const AsyncValue.loading();

    final result = await _subscriptionRepository.restorePurchases();

    return result.fold(
      (failure) {
        state = AsyncValue.data(SubscriptionError(failure));
        return false;
      },
      (subscription) {
        _currentSubscription = subscription;
        _currentTier = subscription?.tier ?? SubscriptionTier.free;
        _updateState();
        return subscription != null;
      },
    );
  }

  /// Sync subscription status
  Future<void> syncStatus(String userId) async {
    await _subscriptionRepository.syncSubscriptionStatus(userId);

    final result = await _subscriptionRepository.getCurrentSubscription(userId);
    result.fold(
      (failure) {},
      (subscription) {
        _currentSubscription = subscription;
        _currentTier = subscription?.tier ?? SubscriptionTier.free;
        _updateState();
      },
    );
  }

  /// Check if user has access to a feature
  Future<bool> hasFeatureAccess(String userId, SubscriptionFeature feature) async {
    final result = await _subscriptionRepository.hasFeatureAccess(userId, feature);
    return result.fold(
      (failure) => false,
      (hasAccess) => hasAccess,
    );
  }

  /// Reset state
  void reset() {
    _subscriptionChanges?.cancel();
    _currentSubscription = null;
    _offerings = [];
    _currentTier = SubscriptionTier.free;
    state = const AsyncValue.data(SubscriptionInitial());
  }

  @override
  void dispose() {
    _subscriptionChanges?.cancel();
    super.dispose();
  }
}

/// Subscription state provider
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, AsyncValue<SubscriptionState>>(
        (ref) {
  final subscriptionRepository = sl<ISubscriptionRepository>();
  final notifier = SubscriptionNotifier(subscriptionRepository);

  // Auto-initialize when user is authenticated
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    notifier.initialize(user.id);
  } else {
    notifier.reset();
  }

  return notifier;
});

/// Current subscription provider (convenience)
final currentSubscriptionProvider = Provider<Subscription?>((ref) {
  final subState = ref.watch(subscriptionProvider);
  return subState.valueOrNull?.subscription;
});

/// Current subscription tier provider
final subscriptionTierProvider = Provider<SubscriptionTier>((ref) {
  final subState = ref.watch(subscriptionProvider);
  return subState.valueOrNull?.tier ?? SubscriptionTier.free;
});

/// Is premium provider
final isPremiumProvider = Provider<bool>((ref) {
  final subState = ref.watch(subscriptionProvider);
  return subState.valueOrNull?.isPremium ?? false;
});

/// Subscription offerings provider
final subscriptionOfferingsProvider = Provider<List<SubscriptionOffering>>((ref) {
  final subState = ref.watch(subscriptionProvider);
  final state = subState.valueOrNull;
  if (state is SubscriptionLoaded) {
    return state.offerings;
  }
  return [];
});

/// Pro offerings provider (monthly and yearly)
final proOfferingsProvider = Provider<List<SubscriptionOffering>>((ref) {
  final offerings = ref.watch(subscriptionOfferingsProvider);
  return offerings.where((o) => o.tier == SubscriptionTier.pro).toList();
});

/// Premium offerings provider (monthly and yearly)
final premiumOfferingsProvider = Provider<List<SubscriptionOffering>>((ref) {
  final offerings = ref.watch(subscriptionOfferingsProvider);
  return offerings.where((o) => o.tier == SubscriptionTier.premium).toList();
});

/// Feature access provider
final featureAccessProvider =
    FutureProvider.family<bool, SubscriptionFeature>((ref, feature) async {
  final subscriptionRepository = sl<ISubscriptionRepository>();
  final user = ref.watch(currentUserProvider);

  if (user == null) return false;

  final result = await subscriptionRepository.hasFeatureAccess(user.id, feature);
  return result.fold(
    (failure) => false,
    (hasAccess) => hasAccess,
  );
});

/// Has ads provider
final hasAdsProvider = Provider<bool>((ref) {
  final tier = ref.watch(subscriptionTierProvider);
  return tier == SubscriptionTier.free;
});

/// Has unlimited quizzes provider
final hasUnlimitedQuizzesProvider = Provider<bool>((ref) {
  final tier = ref.watch(subscriptionTierProvider);
  return tier != SubscriptionTier.free;
});

/// Has unlimited AI chat provider
final hasUnlimitedAiChatProvider = Provider<bool>((ref) {
  final tier = ref.watch(subscriptionTierProvider);
  return tier == SubscriptionTier.pro || tier == SubscriptionTier.premium;
});

/// Has offline access provider
final hasOfflineAccessProvider = Provider<bool>((ref) {
  final tier = ref.watch(subscriptionTierProvider);
  return tier == SubscriptionTier.pro || tier == SubscriptionTier.premium;
});

/// Subscription expiration days provider
final subscriptionExpirationDaysProvider = Provider<int?>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  return subscription?.daysUntilExpiration;
});
