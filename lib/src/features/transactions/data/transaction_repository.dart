import '../../../core/persistence/local_storage.dart';
import '../domain/transaction_record.dart';

abstract class TransactionRepository {
  Future<List<TransactionRecord>> list();
  Future<void> writeAll(List<TransactionRecord> items);
}

final class LocalTransactionRepository implements TransactionRepository {
  LocalTransactionRepository(this._storage);

  static const _key = 'transactions.v1';
  final LocalStorage _storage;

  @override
  Future<List<TransactionRecord>> list() async {
    final raw = _storage.getJsonList(_key);
    if (raw == null) return const [];

    final items = <TransactionRecord>[];
    for (final v in raw) {
      if (v is Map) {
        items.add(TransactionRecord.fromJson(v.cast<String, Object?>()));
      }
    }
    return items;
  }

  @override
  Future<void> writeAll(List<TransactionRecord> items) async {
    await _storage.setJson(
      _key,
      items.map((e) => e.toJson()).toList(growable: false),
    );
  }
}
