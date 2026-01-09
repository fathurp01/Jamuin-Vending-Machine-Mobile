import 'package:dio/dio.dart';

class AdminTransactionItem {
  const AdminTransactionItem({
    required this.id,
    required this.orderId,
    required this.status,
    required this.grossAmount,
    required this.quantity,
    required this.paymentType,
    required this.createdAt,
    required this.productName,
    required this.customerName,
    required this.machineName,
  });

  final int id;
  final String orderId;
  final String status;
  final int grossAmount;
  final int quantity;
  final String? paymentType;
  final DateTime createdAt;
  final String productName;
  final String customerName;
  final String machineName;

  factory AdminTransactionItem.fromJson(Map<String, Object?> json) {
    int toInt(Object? v, {int fallback = 0}) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v.trim()) ?? fallback;
      return fallback;
    }

    DateTime parseCreatedAt(Object? v) {
      if (v is DateTime) return v;
      if (v is String) {
        return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
      }
      if (v is num) {
        // Accept either seconds or milliseconds.
        final asInt = v.toInt();
        final ms = asInt < 100000000000 ? asInt * 1000 : asInt;
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final createdAt = parseCreatedAt(json['createdAt']);

    String getNestedName(Object? v, {required String fallback}) {
      if (v is Map) {
        final map = v.cast<String, Object?>();
        final name = (map['name'] as String?)?.trim();
        if (name != null && name.isNotEmpty) return name;
      }
      return fallback;
    }

    String getNestedProduct(Object? v, {required String fallback}) {
      if (v is Map) {
        final map = v.cast<String, Object?>();
        final name =
            (map['nama'] as String?)?.trim() ??
            (map['name'] as String?)?.trim();
        if (name != null && name.isNotEmpty) return name;
      }
      return fallback;
    }

    return AdminTransactionItem(
      id: toInt(json['id']),
      orderId: (json['orderId'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'pending',
      grossAmount: toInt(json['grossAmount']),
      quantity: toInt(json['quantity'], fallback: 1),
      paymentType: json['paymentType'] as String?,
      createdAt: createdAt,
      productName: getNestedProduct(json['product'], fallback: '-'),
      customerName: getNestedName(json['user'], fallback: '-'),
      machineName: getNestedName(json['machine'], fallback: '-'),
    );
  }
}

abstract class AdminTransactionsRepository {
  Future<List<AdminTransactionItem>> listAll();
}

final class ApiAdminTransactionsRepository
    implements AdminTransactionsRepository {
  ApiAdminTransactionsRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<AdminTransactionItem>> listAll() async {
    final res = await _dio.get<List<dynamic>>('/payments/transactions');
    final data = res.data ?? const [];
    return data
        .whereType<Map>()
        .map((e) => AdminTransactionItem.fromJson(e.cast<String, Object?>()))
        .toList(growable: false);
  }
}
