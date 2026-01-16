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
    int toInt(Object? value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
        final parsedDouble = double.tryParse(value);
        if (parsedDouble != null) return parsedDouble.toInt();
      }
      return fallback;
    }

    return CreatePaymentResult(
      orderId: (json['orderId'] as String?) ?? '',
      snapToken: (json['snapToken'] as String?) ?? '',
      snapUrl: (json['snapUrl'] as String?) ?? '',
      grossAmount: toInt(json['grossAmount']),
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
    // Helper to safely parse int from String or num
    int toInt(Object? value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
        final parsedDouble = double.tryParse(value);
        if (parsedDouble != null) return parsedDouble.toInt();
      }
      return fallback;
    }

    final paidAtRaw = json['paidAt'];
    DateTime? paidAt;
    if (paidAtRaw is String && paidAtRaw.trim().isNotEmpty) {
      paidAt = DateTime.tryParse(paidAtRaw);
    }

    return PaymentStatusDetail(
      orderId: (json['orderId'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'pending',
      paymentType: json['paymentType'] as String?,
      grossAmount: toInt(json['grossAmount']),
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
    // Helper function to safely parse int from dynamic value
    int toInt(Object? value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
        final parsedDouble = double.tryParse(value);
        if (parsedDouble != null) return parsedDouble.toInt();
      }
      return fallback;
    }

    final createdAt =
        DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    final paidAtRaw = json['paidAt'];
    DateTime? paidAt;
    if (paidAtRaw is String && paidAtRaw.trim().isNotEmpty) {
      paidAt = DateTime.tryParse(paidAtRaw);
    }

    return PaymentHistoryItem(
      id: toInt(json['id']),
      orderId: (json['orderId'] as String?) ?? '',
      product: Product.fromJson(
        (json['product'] as Map).cast<String, Object?>(),
      ),
      quantity: toInt(json['quantity'], fallback: 1),
      grossAmount: toInt(json['grossAmount']),
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
    required int machineId,
  });

  Future<PaymentStatusDetail> status(String orderId);

  Future<List<PaymentHistoryItem>> myHistory();

  Future<void> cancel(String orderId);
}

final class ApiPaymentsRepository implements PaymentsRepository {
  ApiPaymentsRepository(this._dio, {required this.platform});

  final Dio _dio;
  final String platform;

  @override
  Future<CreatePaymentResult> create({
    required int productId,
    required int quantity,
    required int machineId,
  }) async {
    final res = await _dio.post<Map<String, Object?>>(
      '/payments/create',
      data: {
        'productId': productId,
        'quantity': quantity,
        'machineId': machineId,
        'platform': platform,
      },
    );
    final data = res.data ?? const <String, Object?>{};
    return CreatePaymentResult.fromJson(data);
  }

  @override
  Future<PaymentStatusDetail> status(String orderId) async {
    int toInt(Object? v, {int fallback = 0}) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v.trim()) ?? fallback;
      return fallback;
    }

    DateTime? parseDateTime(Object? v) {
      if (v is String && v.trim().isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    try {
      final res = await _dio.get<Map<String, Object?>>(
        '/payments/status/$orderId',
      );
      final data = res.data ?? const <String, Object?>{};
      return PaymentStatusDetail.fromJson(data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;

      String message = e.message ?? '';
      if (body is Map) {
        final m = (body['message'] as String?)?.trim();
        if (m != null && m.isNotEmpty) message = m;
      }

      final looksLikeMidtrans404 =
          message.contains('HTTP status code: 404') ||
          message.contains("Transaction doesn't exist") ||
          message.contains('Transaction doesn\'t exist');

      // Temporary resilience: some backend deployments still surface Midtrans 404 as HTTP 400.
      // In that case, fall back to DB transaction data so the status screen can render.
      if (status == 400 && looksLikeMidtrans404) {
        final txRes = await _dio.get<Map<String, Object?>>(
          '/payments/transaction/$orderId',
        );
        final tx = txRes.data ?? const <String, Object?>{};

        final productJson =
            (tx['product'] as Map?)?.cast<String, Object?>() ??
            const <String, Object?>{};
        final userJson =
            (tx['user'] as Map?)?.cast<String, Object?>() ??
            const <String, Object?>{};

        return PaymentStatusDetail(
          orderId: (tx['orderId'] as String?) ?? orderId,
          status: (tx['status'] as String?) ?? 'pending',
          paymentType: tx['paymentType'] as String?,
          grossAmount: toInt(tx['grossAmount']),
          paidAt: parseDateTime(tx['paidAt']),
          product: Product.fromJson(productJson),
          customer: PaymentCustomer.fromJson(userJson),
          midtransStatus: const {
            'status_code': '404',
            'status_message': "Transaction doesn't exist.",
          },
        );
      }

      rethrow;
    }
  }

  @override
  Future<List<PaymentHistoryItem>> myHistory() async {
    final res = await _dio.get<dynamic>('/payments/my-history');
    final body = res.data;

    final List<dynamic> rawList;
    if (body is List) {
      rawList = body;
    } else if (body is Map && body['data'] is List) {
      rawList = body['data'] as List;
    } else {
      rawList = const [];
    }

    return rawList
        .whereType<Map>()
        .map((e) => PaymentHistoryItem.fromJson(e.cast<String, Object?>()))
        .toList(growable: false);
  }

  @override
  Future<void> cancel(String orderId) async {
    await _dio.post<void>('/payments/cancel/$orderId');
  }
}
