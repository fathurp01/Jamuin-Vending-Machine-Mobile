import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/application/session_persistence_providers.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction_record.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final storage = ref.watch(localStorageProvider).requireValue;
  return LocalTransactionRepository(storage);
});

class TransactionHistoryController extends Notifier<List<TransactionRecord>> {
  @override
  List<TransactionRecord> build() {
    unawaited(_load());
    return const [];
  }

  Future<void> _load() async {
    final repo = ref.read(transactionRepositoryProvider);
    final items = await repo.list();
    // Most recent first.
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = items;
  }

  TransactionRecord? getById(String id) {
    return state
        .where((e) => e.id == id)
        .cast<TransactionRecord?>()
        .firstOrNull;
  }

  Future<void> upsert(TransactionRecord record) async {
    final next = [...state];
    final idx = next.indexWhere((e) => e.id == record.id);
    if (idx >= 0) {
      next[idx] = record;
    } else {
      next.insert(0, record);
    }

    state = next;
    await ref.read(transactionRepositoryProvider).writeAll(state);
  }

  Future<void> updateStatus(String id, TransactionStatus status) async {
    final existing = getById(id);
    if (existing == null) return;
    await upsert(existing.copyWith(status: status));
  }

  Future<void> clearAll() async {
    state = const [];
    await ref.read(transactionRepositoryProvider).writeAll(state);
  }
}

final transactionHistoryControllerProvider =
    NotifierProvider<TransactionHistoryController, List<TransactionRecord>>(
      TransactionHistoryController.new,
    );

final transactionByIdProvider = Provider.family<TransactionRecord?, String>((
  ref,
  id,
) {
  final items = ref.watch(transactionHistoryControllerProvider);
  return items.where((e) => e.id == id).cast<TransactionRecord?>().firstOrNull;
});

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
