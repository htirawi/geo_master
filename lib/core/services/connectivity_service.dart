import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'logger_service.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final _connectivityController = StreamController<bool>.broadcast();

  /// Stream of connectivity status (true = connected, false = disconnected)
  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool _isConnected = true;

  /// Current connectivity status
  bool get isConnected => _isConnected;

  /// Initialize the connectivity service and start monitoring
  Future<void> init() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _updateConnectivity(result);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectivity,
      onError: (Object error) {
        logger.error(
          'Connectivity monitoring error',
          tag: 'Connectivity',
          error: error,
        );
      },
    );

    logger.info('Connectivity service initialized', tag: 'Connectivity');
  }

  void _updateConnectivity(List<ConnectivityResult> result) {
    final wasConnected = _isConnected;
    _isConnected = result.isNotEmpty &&
        !result.every((r) => r == ConnectivityResult.none);

    if (wasConnected != _isConnected) {
      logger.info(
        'Connectivity changed: ${_isConnected ? "Connected" : "Disconnected"}',
        tag: 'Connectivity',
      );
      _connectivityController.add(_isConnected);
    }
  }

  /// Check if currently connected to the internet
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectivity(result);
    return _isConnected;
  }

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}

/// Riverpod provider for connectivity service
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

/// Provider for current connectivity status
final isConnectedProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

/// Provider for checking if currently online
final isOnlineProvider = Provider<bool>((ref) {
  final asyncValue = ref.watch(isConnectedProvider);
  return asyncValue.valueOrNull ??
      ref.read(connectivityServiceProvider).isConnected;
});
