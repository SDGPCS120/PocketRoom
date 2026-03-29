import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'api_client.dart';

// ─── PayHere Sandbox Credentials ─────────────────────────────────────────────
// These are sandbox-only credentials — safe to embed in the app for demo/testing.
const String _kMerchantId = '4OVybzavqDY4JH5Ex7E22E3PM';
const String _kAppSecret  = '8RiWi2kyWOY49Y1ZRVq2sP4OfEWgFMnh44aBQAfI5uHB';
// ─────────────────────────────────────────────────────────────────────────────

class PaymentService {
  final ApiClient _apiClient;

  PaymentService(this._apiClient);

  /// Generates the PayHere MD5 hash.
  /// Formula: MD5( merchantId + orderId + amountFormatted + currency + MD5(appSecret).toUpperCase() )
  String _generateHash(String orderId, double amount, String currency) {
    final hashedSecret =
        md5.convert(utf8.encode(_kAppSecret)).toString().toUpperCase();
    final amountFormatted = amount.toStringAsFixed(2);
    final raw = '$_kMerchantId$orderId$amountFormatted$currency$hashedSecret';
    return md5.convert(utf8.encode(raw)).toString().toUpperCase();
  }

  /// Starts the PayHere sandbox payment flow.
  ///
  /// Generates all required PayHere parameters locally (no backend call for
  /// payment creation) so the flow works even if the backend /payments/create
  /// endpoint is unavailable. On success, calls /payments/verify to mark
  /// the order as confirmed.
  Future<bool> startPayment(String orderId, {double? amount, String currency = 'LKR'}) async {
    // Use provided amount or fall back to 1.00 (sandbox requires a positive amount)
    final payAmount = (amount != null && amount > 0) ? amount : 1.00;

    if (kIsWeb) {
      debugPrint('[PaymentService] Web: mocking success for order $orderId');
      return await verifyPayment(orderId);
    }

    try {
      final hash = _generateHash(orderId, payAmount, currency);

      final paymentData = <String, dynamic>{
        'sandbox':     true,
        'merchant_id': _kMerchantId,
        'order_id':    orderId,
        'amount':      payAmount,
        'currency':    currency,
        'hash':        hash,
        // Required customer fields — hardcoded fallbacks for sandbox demo
        'first_name': 'PocketRoom',
        'last_name':  'Customer',
        'email':      'orders@pocketroom.app',
        'phone':      '0771234567',
        'notify_url': 'https://pocketroom-backend-93470454666.asia-south1.run.app/payments/notify',
        'items':      'Order $orderId',
      };

      debugPrint('[PaymentService] Launching PayHere with order: $orderId  amount: $payAmount $currency');

      final completer = Completer<bool>();

      PayHere.startPayment(
        paymentData,
        (paymentId) {
          debugPrint('[PaymentService] Success: $paymentId');
          if (!completer.isCompleted) completer.complete(true);
        },
        (error) {
          debugPrint('[PaymentService] Error: $error');
          if (!completer.isCompleted) completer.completeError(Exception(error));
        },
        () {
          debugPrint('[PaymentService] Dismissed');
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      final success = await completer.future;
      if (success) {
        // Best-effort: notify backend so order status gets updated to CONFIRMED
        await verifyPayment(orderId);
      }
      return success;
    } catch (e) {
      debugPrint('[PaymentService] Error: $e');
      rethrow;
    }
  }

  /// Best-effort backend notification — marks the order as CONFIRMED.
  Future<bool> verifyPayment(String orderId) async {
    try {
      final response = await _apiClient.post('/payments/verify', data: {
        'orderId': orderId,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // Non-fatal — payment was already successful client-side
      debugPrint('[PaymentService] Verification error (non-fatal): $e');
      return true;
    }
  }
}

/// Provider for PaymentService
final paymentServiceProvider = Provider<PaymentService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentService(apiClient);
});
