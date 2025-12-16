import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../transactions/application/transaction_history_controller.dart';
import '../../transactions/domain/transaction_record.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/rounded_card.dart';

class TransactionStatusScreen extends ConsumerWidget {
  const TransactionStatusScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = ref.watch(transactionByIdProvider(transactionId));
    final scheme = Theme.of(context).colorScheme;

    if (tx == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Status'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/app/home'),
          ),
        ),
        body: const Center(child: Text('Transaction not found.')),
      );
    }

    final (title, subtitle, icon) = switch (tx.status) {
      TransactionStatus.pending => (
        'Pending',
        'Waiting for payment confirmation (simulated).',
        Icons.receipt_long_outlined,
      ),
      TransactionStatus.paid => (
        'Paid',
        'Payment confirmed. Please pick up at the machine.',
        Icons.verified_outlined,
      ),
      TransactionStatus.failed => (
        'Failed',
        'Payment failed. Your stock was restored.',
        Icons.error_outline,
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/app/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          RoundedCard(
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
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
                Text('Details', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                _RowKV(label: 'Transaction ID', value: tx.id),
                const SizedBox(height: 8),
                _RowKV(label: 'Machine', value: tx.machineName),
                const SizedBox(height: 8),
                _RowKV(label: 'Customer', value: tx.customer.name),
                const SizedBox(height: 8),
                _RowKV(label: 'Phone', value: tx.customer.phone),
                if ((tx.customer.notes ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _RowKV(label: 'Notes', value: tx.customer.notes!.trim()),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Totals', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                _RowMoney(label: 'Subtotal', amount: tx.subtotal),
                const SizedBox(height: 8),
                _RowMoney(label: 'Service fee', amount: tx.serviceFee),
                const SizedBox(height: 8),
                _RowMoney(label: 'Tax (11%)', amount: tx.tax),
                const Divider(height: 22),
                Row(
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    MoneyText(
                      tx.total,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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
                Text('Items', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ...tx.items.map(
                  (it) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('${it.quantity}× ${it.productName}'),
                        ),
                        MoneyText(it.lineTotal),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => context.go('/app/home'),
            child: const Text('Back to Home'),
          ),
        ],
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

class _RowMoney extends StatelessWidget {
  const _RowMoney({required this.label, required this.amount});

  final String label;
  final int amount;

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
        MoneyText(
          amount,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
