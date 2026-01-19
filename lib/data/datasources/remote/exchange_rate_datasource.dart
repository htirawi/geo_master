import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/exceptions.dart';
import '../../models/exchange_rate_model.dart';

/// Exchange Rate API data source interface
abstract class IExchangeRateDataSource {
  /// Get latest exchange rates for a base currency
  Future<ExchangeRateModel> getLatestRates({String baseCurrency = 'USD'});

  /// Convert amount between currencies
  Future<CurrencyConversionModel> convert({
    required double amount,
    required String from,
    required String to,
  });

  /// Get rate for a specific currency pair
  Future<double> getRate({
    required String from,
    required String to,
  });
}

/// Exchange Rate API data source implementation
class ExchangeRateDataSource implements IExchangeRateDataSource {
  ExchangeRateDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  // Cache for rates to avoid excessive API calls
  ExchangeRateModel? _cachedRates;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(hours: 1);

  @override
  Future<ExchangeRateModel> getLatestRates({String baseCurrency = 'USD'}) async {
    // Check cache first
    if (_cachedRates != null &&
        _cachedRates!.baseCurrency == baseCurrency &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedRates!;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.exchangeRateLatest}/$baseCurrency',
      );

      if (response.statusCode == 200 && response.data != null) {
        final rates = ExchangeRateModel.fromJson(response.data!);
        _cachedRates = rates;
        _cacheTime = DateTime.now();
        return rates;
      }

      throw ServerException(
        message: 'Failed to fetch exchange rates',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Exchange rate API error: $e');
    }
  }

  @override
  Future<CurrencyConversionModel> convert({
    required double amount,
    required String from,
    required String to,
  }) async {
    final rates = await getLatestRates(baseCurrency: from);
    final rate = rates.getRate(to);

    if (rate == null) {
      throw ServerException(
        message: 'Currency $to not supported',
        code: 'UNSUPPORTED_CURRENCY',
      );
    }

    final convertedAmount = amount * rate;

    return CurrencyConversionModel(
      fromCurrency: from,
      toCurrency: to,
      amount: amount,
      convertedAmount: convertedAmount,
      rate: rate,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<double> getRate({
    required String from,
    required String to,
  }) async {
    final rates = await getLatestRates(baseCurrency: from);
    final rate = rates.getRate(to);

    if (rate == null) {
      throw ServerException(
        message: 'Currency pair $from/$to not supported',
        code: 'UNSUPPORTED_PAIR',
      );
    }

    return rate;
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timed out. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection. Please check your network.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return const ServerException(
            message: 'Currency not found',
            code: 'CURRENCY_NOT_FOUND',
            statusCode: 404,
          );
        }
        return ServerException(
          message: 'Exchange rate server error',
          statusCode: statusCode,
        );
      default:
        return ServerException(
          message: e.message ?? 'Exchange rate API error',
        );
    }
  }
}
