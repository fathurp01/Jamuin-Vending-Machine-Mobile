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
    final createdAt =
        DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);

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
      id: ((json['id'] as num?) ?? 0).toInt(),
      orderId: (json['orderId'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'pending',
      grossAmount: ((json['grossAmount'] as num?) ?? 0).toInt(),
      quantity: ((json['quantity'] as num?) ?? 1).toInt(),
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
