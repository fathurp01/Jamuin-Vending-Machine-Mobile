import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/checkout_controller.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/rounded_card.dart';

class TransactionStatusScreen extends ConsumerWidget {
  const TransactionStatusScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = ref.watch(checkoutControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    final status = tx?.status ?? TransactionStatus.pending;
    final total = tx?.total ?? 0;

    String title;
    String subtitle;
    IconData icon;

    switch (status) {
      case TransactionStatus.pending:
        title = 'Order received';
        subtitle = 'We are starting your order.';
        icon = Icons.receipt_long_outlined;
        break;
      case TransactionStatus.brewing:
        title = 'Preparing';
        subtitle = 'Your drink is being prepared.';
        icon = Icons.local_cafe_outlined;
        break;
      case TransactionStatus.ready:
        title = 'Ready for pickup';
        subtitle = 'Please pick up at the selected machine.';
        icon = Icons.check_circle_outline;
        break;
      case TransactionStatus.completed:
        title = 'Completed';
        subtitle = 'Thank you! Enjoy your order.';
        icon = Icons.verified_outlined;
        break;
      case TransactionStatus.failed:
        title = 'Failed';
        subtitle = 'Something went wrong. Please try again.';
        icon = Icons.error_outline;
        break;
    }

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
                const SizedBox(width: 14),
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
                Text(
                  'Transaction',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'ID',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      transactionId,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    MoneyText(
                      total,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
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
                Text(
                  'Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _StepRow(
                  done: status.index >= TransactionStatus.pending.index,
                  label: 'Order received',
                ),
                _StepRow(
                  done: status.index >= TransactionStatus.brewing.index,
                  label: 'Preparing',
                ),
                _StepRow(
                  done: status.index >= TransactionStatus.ready.index,
                  label: 'Ready for pickup',
                ),
                _StepRow(
                  done: status.index >= TransactionStatus.completed.index,
                  label: 'Completed',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: FilledButton(
          onPressed: () => context.go('/app/home'),
          child: const Text('Back to Home'),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.done, required this.label});

  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: done
                  ? scheme.primary
                  : scheme.onSurfaceVariant.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: done
                ? Icon(Icons.check, size: 14, color: scheme.onPrimary)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: done ? FontWeight.w800 : FontWeight.w500,
                color: done ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
