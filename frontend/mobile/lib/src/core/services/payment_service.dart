import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'api_client.dart';

class PaymentService {
  final ApiClient _apiClient;

  PaymentService(this._apiClient);

  /// Starts the payment process
  /// 
  /// If kIsWeb, mocks a successful payment.
  /// On mobile, calls the backend to get payment details and starts PayHere SDK.
  Future<bool> startPayment(String orderId) async {
    if (kIsWeb) {
      debugPrint('[PaymentService] Web detected, mocking success for order: $orderId');
      // On web we call verify directly as instructed
      return await verifyPayment(orderId);
    }

    try {
      // 1. Get payment details from backend
      // POST /payments/create returns the PayHere payment object
      final response = await _apiClient.post('/payments/create', data: {
        'orderId': orderId,
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create payment on backend');
      }

      // Backend wraps all responses as { success, data: {...}, meta }
      final envelope = response.data as Map<String, dynamic>?;
      final inner = envelope?['data'] as Map<String, dynamic>?;
      if (inner == null) {
        throw Exception('Invalid payment response from server');
      }
      final paymentData = Map<String, dynamic>.from(inner);
      
      // Ensure sandbox flag is present for sandbox credentials
      paymentData['sandbox'] = true;

      // 2. Start PayHere Payment
      final completer = Completer<bool>();

      PayHere.startPayment(
        paymentData,
        (paymentId) {
          debugPrint('[PaymentService] Payment Success: $paymentId');
          if (!completer.isCompleted) completer.complete(true);
        },
        (error) {
          debugPrint('[PaymentService] Payment Error: $error');
          if (!completer.isCompleted) completer.completeError(error);
        },
        () {
          debugPrint('[PaymentService] Payment Dismissed');
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      final success = await completer.future;
      if (success) {
        // 3. Verify on backend after success
        return await verifyPayment(orderId);
      }
      return false;
    } catch (e) {
      debugPrint('[PaymentService] Error: $e');
      rethrow;
    }
  }

  /// Verifies the payment on the backend
  Future<bool> verifyPayment(String orderId) async {
    try {
      final response = await _apiClient.post('/payments/verify', data: {
        'orderId': orderId,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('[PaymentService] Verification Error: $e');
      return false;
    }
  }
}

/// Provider for PaymentService
final paymentServiceProvider = Provider<PaymentService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentService(apiClient);
});
