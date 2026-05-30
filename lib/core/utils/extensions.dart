import 'package:intl/intl.dart';
import 'package:takturns_flutter_app/core/constants/app_constants.dart';

extension BigIntFormatting on BigInt {
  /// Convert raw USDC (6 decimals) to display string e.g. "10.00 USDC"
  String toUsdc({int decimalPlaces = 2}) {
    final divisor = BigInt.from(10).pow(AppConstants.usdcDecimals);
    final whole = this ~/ divisor;
    final fraction = (this % divisor).toInt();
    final fractionStr = fraction.toString().padLeft(AppConstants.usdcDecimals, '0');
    final truncated = fractionStr.substring(0, decimalPlaces);
    return '$whole.$truncated USDC';
  }

  /// Convert USDC display amount (double) to raw BigInt
  static BigInt fromUsdcDouble(double amount) {
    return BigInt.from((amount * 1e6).round());
  }
}

extension AddressFormatting on String {
  /// Truncate Ethereum address: 0x1234...5678
  String get truncated {
    if (length < 10) return this;
    return '${substring(0, 6)}...${substring(length - 4)}';
  }

  bool get isValidEthAddress {
    final regex = RegExp(r'^0x[0-9a-fA-F]{40}$');
    return regex.hasMatch(this);
  }

  bool get isValidPrivateKey {
    final clean = startsWith('0x') ? substring(2) : this;
    final regex = RegExp(r'^[0-9a-fA-F]{64}$');
    return regex.hasMatch(clean);
  }
}

extension DurationFormatting on int {
  /// Format cycle duration in seconds to human-readable
  String get cycleDurationLabel {
    final days = this ~/ 86400;
    if (days == 7) return 'Weekly';
    if (days == 14) return 'Bi-weekly';
    if (days >= 28 && days <= 31) return 'Monthly';
    return '$days days';
  }
}

extension TimestampFormatting on int {
  String get toDateTimeStr {
    final dt = DateTime.fromMillisecondsSinceEpoch(this * 1000);
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  String get toDeadlineStr {
    final dt = DateTime.fromMillisecondsSinceEpoch(this * 1000);
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.isNegative) return 'Overdue';
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h left';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m left';
    return '${diff.inMinutes}m left';
  }
}
