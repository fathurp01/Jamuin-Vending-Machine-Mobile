import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../transactions/application/payments_providers.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/rounded_card.dart';

class TransactionStatusScreen extends ConsumerWidget {
  const TransactionStatusScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final statusAsync = ref.watch(paymentStatusProvider(transactionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/app/home'),
        ),
      ),
      body: statusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Failed to load status.\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (detail) {
          final normalized = detail.status.trim().toLowerCase();

          final (title, subtitle, icon, color) = switch (normalized) {
            'paid' || 'settlement' => (
              'Paid',
              'Payment confirmed. Please pick up at the machine.',
              Icons.verified_outlined,
              scheme.primary,
            ),
            'failed' || 'expire' || 'cancel' || 'deny' => (
              'Failed',
              'Payment was not completed.',
              Icons.error_outline,
              scheme.error,
            ),
            _ => (
              'Pending',
              'Waiting for payment confirmation.',
              Icons.receipt_long_outlined,
              scheme.secondary,
            ),
          };

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              RoundedCard(
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              RoundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    _RowKV(label: 'Order ID', value: detail.orderId),
                    const SizedBox(height: 8),
                    _RowKV(label: 'Status', value: detail.status),
                    if ((detail.paymentType ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _RowKV(
                        label: 'Payment type',
                        value: detail.paymentType!.trim(),
                      ),
                    ],
                    if (detail.paidAt != null) ...[
                      const SizedBox(height: 8),
                      _RowKV(
                        label: 'Paid at',
                        value: detail.paidAt!.toLocal().toString(),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _RowKV(label: 'Customer', value: detail.customer.name),
                    const SizedBox(height: 8),
                    _RowKV(label: 'Email', value: detail.customer.email),
                    const SizedBox(height: 8),
                    _RowKV(label: 'Phone', value: detail.customer.phone),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              RoundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: Text(detail.product.name)),
                        MoneyText(detail.product.price),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              RoundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Gross amount',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const Spacer(),
                        MoneyText(
                          detail.grossAmount,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => context.go('/app/history'),
                child: const Text('View history'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () =>
                    ref.invalidate(paymentStatusProvider(transactionId)),
                child: const Text('Refresh status'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RowKV extends StatelessWidget {
  const _RowKV({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
