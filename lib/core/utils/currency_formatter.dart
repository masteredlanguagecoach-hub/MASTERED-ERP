import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  static String format(num? amount, {String symbol = AppConstants.defaultCurrency}) {
    if (amount == null) return '$symbol0';
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: symbol,
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatCompact(num? amount, {String symbol = AppConstants.defaultCurrency}) {
    if (amount == null) return '$symbol0';
    if (amount >= 10000000) {
      return '$symbol${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '$symbol${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)} k';
    }
    return format(amount, symbol: symbol);
  }
}
