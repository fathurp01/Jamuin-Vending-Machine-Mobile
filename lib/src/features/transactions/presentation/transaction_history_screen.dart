import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import '../application/payments_providers.dart';
import '../../session/application/session_controller.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/rounded_card.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final session = ref.watch(sessionControllerProvider);
    final token = (session.token ?? '').trim();

    // Gate history by token presence (server requires JWT). Do not rely solely
    // on `isAuthenticated` to avoid false negatives.
    if (token.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 44,
                  color: scheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 10),
                Text(
                  'Login untuk melihat riwayat transaksi',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => context.go(
                    '/auth/login?redirect=${Uri.encodeComponent('/app/history')}',
                  ),
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final historyAsync = ref.watch(paymentHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final isAuthError =
              e is DioException &&
              ((e.response?.statusCode ?? 0) == 401 ||
                  (e.response?.statusCode ?? 0) == 403);

          if (isAuthError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 44,
                      color: scheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Akses riwayat ditolak oleh server. Silakan login ulang.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () => context.go(
                        '/auth/login?redirect=${Uri.encodeComponent('/app/history')}',
                      ),
                      child: const Text('Login ulang'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gagal memuat riwayat.\n$e',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 44,
                    color: scheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Anda belum melakukan transaksi',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan pilih produk untuk mulai belanja.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () => context.go('/app/products'),
                    child: const Text('Lihat produk'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(paymentHistoryProvider);
              await ref.read(paymentHistoryProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tx = items[index];
                final normalized = tx.status.trim().toLowerCase();
                final dateText = MaterialLocalizations.of(
                  context,
                ).formatShortDate(tx.createdAt.toLocal());
                final paymentType = (tx.paymentType ?? '').trim();

                final (title, color, icon) = switch (normalized) {
                  'success' || 'paid' || 'settlement' => (
                    'Berhasil',
                    scheme.primary,
                    Icons.check_circle_outline,
                  ),
                  'failed' ||
                  'expire' ||
                  'expired' ||
                  'cancel' ||
                  'cancelled' ||
                  'deny' => ('Gagal', scheme.error, Icons.error_outline),
                  _ => ('Menunggu', scheme.secondary, Icons.schedule_outlined),
                };

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => context.push('/app/tx/${tx.orderId}'),
                  child: RoundedCard(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, color: color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      tx.orderId,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                  Text(
                                    title,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: color,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${tx.quantity}× ${tx.product.name}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                paymentType.isEmpty
                                    ? dateText
                                    : '$dateText • $paymentType',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
                              ),
                              const SizedBox(height: 6),
                              MoneyText(
                                tx.grossAmount,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: scheme.onSurface.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
