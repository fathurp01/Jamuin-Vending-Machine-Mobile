import 'package:dio/dio.dart';

import '../../products/domain/product.dart';

class CreatePaymentResult {
  const CreatePaymentResult({
    required this.orderId,
    required this.snapToken,
    required this.snapUrl,
    required this.grossAmount,
    required this.product,
  });

  final String orderId;
  final String snapToken;
  final String snapUrl;
  final int grossAmount;
  final Product product;

  factory CreatePaymentResult.fromJson(Map<String, Object?> json) {
    return CreatePaymentResult(
      orderId: (json['orderId'] as String?) ?? '',
      snapToken: (json['snapToken'] as String?) ?? '',
      snapUrl: (json['snapUrl'] as String?) ?? '',
      grossAmount: ((json['grossAmount'] as num?) ?? 0).toInt(),
      product: Product.fromJson(
        (json['product'] as Map).cast<String, Object?>(),
      ),
    );
  }
}

class PaymentCustomer {
  const PaymentCustomer({
    required this.name,
    required this.email,
    required this.phone,
  });

  final String name;
  final String email;
  final String phone;

  factory PaymentCustomer.fromJson(Map<String, Object?> json) {
    return PaymentCustomer(
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
    );
  }
}

class PaymentStatusDetail {
  const PaymentStatusDetail({
    required this.orderId,
    required this.status,
    required this.paymentType,
    required this.grossAmount,
    required this.paidAt,
    required this.product,
    required this.customer,
    required this.midtransStatus,
  });

  final String orderId;
  final String status;
  final String? paymentType;
  final int grossAmount;
  final DateTime? paidAt;
  final Product product;
  final PaymentCustomer customer;
  final Map<String, Object?> midtransStatus;

  factory PaymentStatusDetail.fromJson(Map<String, Object?> json) {
    final paidAtRaw = json['paidAt'];
    DateTime? paidAt;
    if (paidAtRaw is String && paidAtRaw.trim().isNotEmpty) {
      paidAt = DateTime.tryParse(paidAtRaw);
    }

    return PaymentStatusDetail(
      orderId: (json['orderId'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'pending',
      paymentType: json['paymentType'] as String?,
      grossAmount: ((json['grossAmount'] as num?) ?? 0).toInt(),
      paidAt: paidAt,
      product: Product.fromJson(
        (json['product'] as Map).cast<String, Object?>(),
      ),
      customer: PaymentCustomer.fromJson(
        (json['customer'] as Map).cast<String, Object?>(),
      ),
      midtransStatus:
          (json['midtransStatus'] as Map?)?.cast<String, Object?>() ?? const {},
    );
  }
}

class PaymentHistoryItem {
  const PaymentHistoryItem({
    required this.id,
    required this.orderId,
    required this.product,
    required this.quantity,
    required this.grossAmount,
    required this.status,
    required this.paymentType,
    required this.platform,
    required this.createdAt,
    required this.paidAt,
  });

  final int id;
  final String orderId;
  final Product product;
  final int quantity;
  final int grossAmount;
  final String status;
  final String? paymentType;
  final String? platform;
  final DateTime createdAt;
  final DateTime? paidAt;

  factory PaymentHistoryItem.fromJson(Map<String, Object?> json) {
    final createdAt =
        DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    final paidAtRaw = json['paidAt'];
    DateTime? paidAt;
    if (paidAtRaw is String && paidAtRaw.trim().isNotEmpty) {
      paidAt = DateTime.tryParse(paidAtRaw);
    }

    return PaymentHistoryItem(
      id: ((json['id'] as num?) ?? 0).toInt(),
      orderId: (json['orderId'] as String?) ?? '',
      product: Product.fromJson(
        (json['product'] as Map).cast<String, Object?>(),
      ),
      quantity: ((json['quantity'] as num?) ?? 1).toInt(),
      grossAmount: ((json['grossAmount'] as num?) ?? 0).toInt(),
      status: (json['status'] as String?) ?? 'pending',
      paymentType: json['paymentType'] as String?,
      platform: json['platform'] as String?,
      createdAt: createdAt,
      paidAt: paidAt,
    );
  }
}

abstract class PaymentsRepository {
  Future<CreatePaymentResult> create({
    required int productId,
    required int quantity,
  });

  Future<PaymentStatusDetail> status(String orderId);

  Future<List<PaymentHistoryItem>> myHistory();
}

final class ApiPaymentsRepository implements PaymentsRepository {
  ApiPaymentsRepository(this._dio, {required this.platform});

  final Dio _dio;
  final String platform;

  @override
  Future<CreatePaymentResult> create({
    required int productId,
    required int quantity,
  }) async {
    final res = await _dio.post<Map<String, Object?>>(
      '/payments/create',
      data: {
        'productId': productId,
        'quantity': quantity,
        'platform': platform,
      },
    );
    final data = res.data ?? const <String, Object?>{};
    return CreatePaymentResult.fromJson(data);
  }

  @override
  Future<PaymentStatusDetail> status(String orderId) async {
    final res = await _dio.get<Map<String, Object?>>(
      '/payments/status/$orderId',
    );
    final data = res.data ?? const <String, Object?>{};
    return PaymentStatusDetail.fromJson(data);
  }

  @override
  Future<List<PaymentHistoryItem>> myHistory() async {
    final res = await _dio.get<List<dynamic>>('/payments/my-history');
    final data = res.data ?? const [];
    return data
        .whereType<Map>()
        .map((e) => PaymentHistoryItem.fromJson(e.cast<String, Object?>()))
        .toList(growable: false);
  }
}
