enum TransactionStatus { pending, paid, failed }

class TransactionLineItem {
  const TransactionLineItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final String productName;
  final int unitPrice;
  final int quantity;

  int get lineTotal => unitPrice * quantity;

  Map<String, Object?> toJson() => {
    'productId': productId,
    'productName': productName,
    'unitPrice': unitPrice,
    'quantity': quantity,
  };

  static TransactionLineItem fromJson(Map<String, Object?> json) {
    return TransactionLineItem(
      productId: (json['productId'] as String?) ?? '',
      productName: (json['productName'] as String?) ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }
}

class CustomerInfo {
  const CustomerInfo({required this.name, required this.phone, this.notes});

  final String name;
  final String phone;
  final String? notes;

  Map<String, Object?> toJson() => {
    'name': name,
    'phone': phone,
    'notes': notes,
  };

  static CustomerInfo fromJson(Map<String, Object?> json) {
    return CustomerInfo(
      name: (json['name'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      notes: json['notes'] as String?,
    );
  }
}

class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.createdAt,
    required this.machineId,
    required this.machineName,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.serviceFee,
    required this.tax,
    required this.total,
    required this.customer,
  });

  final String id;
  final DateTime createdAt;
  final String machineId;
  final String machineName;
  final TransactionStatus status;
  final List<TransactionLineItem> items;
  final int subtotal;
  final int serviceFee;
  final int tax;
  final int total;
  final CustomerInfo customer;

  TransactionRecord copyWith({TransactionStatus? status}) {
    return TransactionRecord(
      id: id,
      createdAt: createdAt,
      machineId: machineId,
      machineName: machineName,
      status: status ?? this.status,
      items: items,
      subtotal: subtotal,
      serviceFee: serviceFee,
      tax: tax,
      total: total,
      customer: customer,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'machineId': machineId,
    'machineName': machineName,
    'status': status.name,
    'items': items.map((e) => e.toJson()).toList(),
    'subtotal': subtotal,
    'serviceFee': serviceFee,
    'tax': tax,
    'total': total,
    'customer': customer.toJson(),
  };

  static TransactionRecord fromJson(Map<String, Object?> json) {
    final statusRaw = (json['status'] as String?) ?? 'pending';
    final status = switch (statusRaw) {
      'paid' => TransactionStatus.paid,
      'failed' => TransactionStatus.failed,
      _ => TransactionStatus.pending,
    };

    final itemsRaw = json['items'];
    final items = <TransactionLineItem>[];
    if (itemsRaw is List) {
      for (final v in itemsRaw) {
        if (v is Map) {
          items.add(TransactionLineItem.fromJson(v.cast<String, Object?>()));
        }
      }
    }

    final customerRaw = json['customer'];
    final customer = customerRaw is Map
        ? CustomerInfo.fromJson(customerRaw.cast<String, Object?>())
        : const CustomerInfo(name: '', phone: '');

    return TransactionRecord(
      id: (json['id'] as String?) ?? '',
      createdAt:
          DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      machineId: (json['machineId'] as String?) ?? '',
      machineName: (json['machineName'] as String?) ?? '',
      status: status,
      items: items,
      subtotal: (json['subtotal'] as num?)?.toInt() ?? 0,
      serviceFee: (json['serviceFee'] as num?)?.toInt() ?? 0,
      tax: (json['tax'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      customer: customer,
    );
  }
}
