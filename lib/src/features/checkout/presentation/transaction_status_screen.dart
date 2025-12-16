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
                  final tx = ref.watch(transactionByIdProvider(transactionId));
                  child: Icon(icon, color: scheme.primary),
                ),

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

                  final status = tx.status;
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                      title = 'Pending';
                      subtitle = 'Waiting for payment confirmation (simulated).';
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                      title = 'Paid';
                      subtitle = 'Payment confirmed. Please pick up at the machine.';
                      icon = Icons.verified_outlined;
                      break;
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                      subtitle = 'Payment failed. Your stock was restored.';
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
                                    tx.machineName,
            ),
          ),
          const SizedBox(height: 12),
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Customer',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    tx.customer.name,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
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
                                    tx.total,
                  label: 'Preparing',
                ),
                _StepRow(
                  done: status.index >= TransactionStatus.ready.index,
                  label: 'Ready for pickup',
                ),
                              const Divider(height: 22),
                              Row(
                                children: [
                                  Text(
                                    'Subtotal',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const Spacer(),
                                  MoneyText(
                                    tx.subtotal,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Service fee',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const Spacer(),
                                  MoneyText(
                                    tx.serviceFee,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Tax (11%)',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const Spacer(),
                                  MoneyText(
                                    tx.tax,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
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
                                'Items',
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: FilledButton(
                              const SizedBox(height: 10),
                              ...tx.items.map(
                                (it) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text('${it.quantity}× ${it.productName}')),
                                      MoneyText(it.lineTotal),
                                    ],
                                  ),
                                ),
                              ),

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

