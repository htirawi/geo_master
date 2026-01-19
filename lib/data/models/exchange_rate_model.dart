/// Exchange rate model for currency conversion
class ExchangeRateModel {
  const ExchangeRateModel({
    required this.baseCurrency,
    required this.date,
    required this.rates,
    this.provider,
    this.lastUpdated,
  });

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    // Parse rates
    final ratesData = json['rates'] as Map<String, dynamic>? ?? {};
    final rates = <String, double>{};
    for (final entry in ratesData.entries) {
      final value = entry.value;
      if (value is num) {
        rates[entry.key] = value.toDouble();
      }
    }

    return ExchangeRateModel(
      baseCurrency: json['base'] as String? ?? 'USD',
      date: json['date'] as String? ?? '',
      rates: rates,
      provider: json['provider'] as String?,
      lastUpdated: json['time_last_updated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              ((json['time_last_updated'] as num) * 1000).toInt())
          : null,
    );
  }

  final String baseCurrency;
  final String date;
  final Map<String, double> rates;
  final String? provider;
  final DateTime? lastUpdated;

  Map<String, dynamic> toJson() {
    return {
      'base': baseCurrency,
      'date': date,
      'rates': rates,
      'provider': provider,
      'time_last_updated': lastUpdated?.millisecondsSinceEpoch,
    };
  }

  /// Get rate for a specific currency
  double? getRate(String currencyCode) {
    return rates[currencyCode.toUpperCase()];
  }

  /// Convert amount from base currency to target currency
  double? convert(double amount, String targetCurrency) {
    final rate = getRate(targetCurrency);
    if (rate == null) return null;
    return amount * rate;
  }

  /// Convert between two currencies
  double? convertBetween(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) {
    if (fromCurrency.toUpperCase() == baseCurrency.toUpperCase()) {
      return convert(amount, toCurrency);
    }

    final fromRate = getRate(fromCurrency);
    final toRate = getRate(toCurrency);

    if (fromRate == null || toRate == null) return null;

    // Convert to base currency first, then to target
    final inBase = amount / fromRate;
    return inBase * toRate;
  }

  /// Get all available currency codes
  List<String> get availableCurrencies => rates.keys.toList()..sort();
}

/// Currency info model
class CurrencyInfoModel {
  const CurrencyInfoModel({
    required this.code,
    required this.name,
    required this.symbol,
    this.country,
    this.decimalDigits = 2,
  });

  factory CurrencyInfoModel.fromJson(Map<String, dynamic> json) {
    return CurrencyInfoModel(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      country: json['country'] as String?,
      decimalDigits: (json['decimal_digits'] as num?)?.toInt() ?? 2,
    );
  }

  final String code;
  final String name;
  final String symbol;
  final String? country;
  final int decimalDigits;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'country': country,
      'decimal_digits': decimalDigits,
    };
  }

  /// Format amount with currency symbol
  String formatAmount(double amount) {
    return '$symbol${amount.toStringAsFixed(decimalDigits)}';
  }
}

/// Currency conversion result model
class CurrencyConversionModel {
  const CurrencyConversionModel({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.convertedAmount,
    required this.rate,
    required this.timestamp,
  });

  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double convertedAmount;
  final double rate;
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'from': fromCurrency,
      'to': toCurrency,
      'amount': amount,
      'converted': convertedAmount,
      'rate': rate,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Get formatted conversion string
  String get formattedConversion {
    return '${amount.toStringAsFixed(2)} $fromCurrency = ${convertedAmount.toStringAsFixed(2)} $toCurrency';
  }

  /// Get rate string
  String get rateString {
    return '1 $fromCurrency = ${rate.toStringAsFixed(4)} $toCurrency';
  }
}

/// Common currency codes
abstract final class CurrencyCodes {
  static const String usd = 'USD';
  static const String eur = 'EUR';
  static const String gbp = 'GBP';
  static const String jpy = 'JPY';
  static const String cny = 'CNY';
  static const String inr = 'INR';
  static const String aud = 'AUD';
  static const String cad = 'CAD';
  static const String chf = 'CHF';
  static const String aed = 'AED';
  static const String sar = 'SAR';
  static const String egp = 'EGP';
}
