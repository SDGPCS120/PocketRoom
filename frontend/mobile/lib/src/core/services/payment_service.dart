import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api_client.dart';

class PendingCheckout {
  const PendingCheckout(this.orderId, this.quantities);

  final String orderId;
  final Map<String, int> quantities;
}

class PaymentService {
  PaymentService(this._apiClient);

  final ApiClient _apiClient;
  final pendingCheckouts = <String, PendingCheckout>{};

  Map<String, dynamic> _data(dynamic body) {
    final response = body as Map<String, dynamic>;
    return response['data'] as Map<String, dynamic>;
  }

  Future<Uri?> prepareCheckout(String orderId) async {
    final response = await _apiClient.post(
      '/payments/create',
      data: {'orderId': orderId},
    );
    final checkoutUrl = _data(response.data)['checkoutUrl'] as String?;
    if (checkoutUrl == null) return null;
    final uri = Uri.parse(checkoutUrl);
    if (uri.scheme != 'https' || uri.host.isEmpty) {
      throw const FormatException('Invalid checkout link');
    }
    return uri;
  }

  Future<void> openCheckout(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw StateError('Unable to open PayHere checkout');
    }
  }

  Future<String> paymentStatus(String orderId) async {
    final response = await _apiClient.get(
      '/payments/order/${Uri.encodeComponent(orderId)}',
    );
    return _data(response.data)['paymentStatus'] as String;
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(ref.watch(apiClientProvider));
});
