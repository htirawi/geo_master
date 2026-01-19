import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/service_locator.dart';
import '../../data/models/exchange_rate_model.dart';
import '../../domain/repositories/i_media_repository.dart';

/// Exchange rates provider
final exchangeRatesProvider = FutureProvider.family<ExchangeRateModel?, String>(
  (ref, baseCurrency) async {
    final repository = sl<IMediaRepository>();

    final result = await repository.getExchangeRates(baseCurrency: baseCurrency);
    return result.fold(
      (_) => null,
      (rates) => rates,
    );
  },
);

/// USD exchange rates (default)
final usdExchangeRatesProvider = FutureProvider<ExchangeRateModel?>(
  (ref) async {
    final repository = sl<IMediaRepository>();

    final result = await repository.getExchangeRates(baseCurrency: 'USD');
    return result.fold(
      (_) => null,
      (rates) => rates,
    );
  },
);

/// Currency conversion state
class CurrencyConversionState {
  const CurrencyConversionState({
    this.amount = 100,
    this.fromCurrency = 'USD',
    this.toCurrency = 'EUR',
    this.result,
    this.rate,
    this.isLoading = false,
    this.error,
  });

  final double amount;
  final String fromCurrency;
  final String toCurrency;
  final double? result;
  final double? rate;
  final bool isLoading;
  final String? error;

  CurrencyConversionState copyWith({
    double? amount,
    String? fromCurrency,
    String? toCurrency,
    double? result,
    double? rate,
    bool? isLoading,
    String? error,
  }) {
    return CurrencyConversionState(
      amount: amount ?? this.amount,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      result: result ?? this.result,
      rate: rate ?? this.rate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Currency conversion notifier
class CurrencyConversionNotifier extends StateNotifier<CurrencyConversionState> {
  CurrencyConversionNotifier(this._repository)
      : super(const CurrencyConversionState());

  final IMediaRepository _repository;

  /// Set amount to convert
  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
    _convert();
  }

  /// Set from currency
  void setFromCurrency(String currency) {
    state = state.copyWith(fromCurrency: currency);
    _convert();
  }

  /// Set to currency
  void setToCurrency(String currency) {
    state = state.copyWith(toCurrency: currency);
    _convert();
  }

  /// Swap currencies
  void swapCurrencies() {
    state = state.copyWith(
      fromCurrency: state.toCurrency,
      toCurrency: state.fromCurrency,
    );
    _convert();
  }

  /// Perform conversion
  Future<void> _convert() async {
    if (state.fromCurrency == state.toCurrency) {
      state = state.copyWith(
        result: state.amount,
        rate: 1.0,
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.convertCurrency(
      amount: state.amount,
      from: state.fromCurrency,
      to: state.toCurrency,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (conversion) => state = state.copyWith(
        result: conversion.convertedAmount,
        rate: conversion.rate,
        isLoading: false,
      ),
    );
  }

  /// Initial conversion
  Future<void> convert() async {
    await _convert();
  }
}

/// Currency conversion provider
final currencyConversionProvider =
    StateNotifierProvider<CurrencyConversionNotifier, CurrencyConversionState>(
  (ref) {
    final repository = sl<IMediaRepository>();
    final notifier = CurrencyConversionNotifier(repository);
    notifier.convert();
    return notifier;
  },
);

/// Get rate for a currency pair
final currencyRateProvider = FutureProvider.family<double?, (String, String)>(
  (ref, params) async {
    final (from, to) = params;
    final repository = sl<IMediaRepository>();

    final result = await repository.getExchangeRate(from: from, to: to);
    return result.fold(
      (_) => null,
      (rate) => rate,
    );
  },
);

/// Common currencies list
final commonCurrenciesProvider = Provider<List<String>>((ref) {
  return [
    'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR',
    'AUD', 'CAD', 'CHF', 'AED', 'SAR', 'EGP',
    'KRW', 'BRL', 'MXN', 'RUB', 'TRY', 'ZAR',
    'SGD', 'HKD', 'NZD', 'SEK', 'NOK', 'DKK',
  ];
});

/// Currency info (name and symbol)
final currencyInfoProvider = Provider.family<(String, String), String>(
  (ref, code) {
    const currencyInfo = {
      'USD': ('US Dollar', '\$'),
      'EUR': ('Euro', '€'),
      'GBP': ('British Pound', '£'),
      'JPY': ('Japanese Yen', '¥'),
      'CNY': ('Chinese Yuan', '¥'),
      'INR': ('Indian Rupee', '₹'),
      'AUD': ('Australian Dollar', 'A\$'),
      'CAD': ('Canadian Dollar', 'C\$'),
      'CHF': ('Swiss Franc', 'CHF'),
      'AED': ('UAE Dirham', 'د.إ'),
      'SAR': ('Saudi Riyal', '﷼'),
      'EGP': ('Egyptian Pound', 'E£'),
      'KRW': ('Korean Won', '₩'),
      'BRL': ('Brazilian Real', 'R\$'),
      'MXN': ('Mexican Peso', '\$'),
      'RUB': ('Russian Ruble', '₽'),
      'TRY': ('Turkish Lira', '₺'),
      'ZAR': ('South African Rand', 'R'),
      'SGD': ('Singapore Dollar', 'S\$'),
      'HKD': ('Hong Kong Dollar', 'HK\$'),
      'NZD': ('New Zealand Dollar', 'NZ\$'),
      'SEK': ('Swedish Krona', 'kr'),
      'NOK': ('Norwegian Krone', 'kr'),
      'DKK': ('Danish Krone', 'kr'),
    };

    return currencyInfo[code] ?? (code, code);
  },
);
