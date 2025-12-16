import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/transaction_history_controller.dart';
import '../domain/transaction_record.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/rounded_card.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(transactionHistoryControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 44,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No transactions yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your completed and pending orders will appear here.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tx = items[index];

                final (title, color, icon) = switch (tx.status) {
                  TransactionStatus.pending => (
                    'Pending',
                    scheme.secondary,
                    Icons.schedule_outlined,
                  ),
                  TransactionStatus.paid => (
                    'Paid',
                    scheme.primary,
                    Icons.check_circle_outline,
                  ),
                  TransactionStatus.failed => (
                    'Failed',
                    scheme.error,
                    Icons.error_outline,
                  ),
                };

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => context.push('/app/tx/${tx.id}'),
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
                                      tx.id,
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
                                tx.machineName,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 6),
                              MoneyText(
                                tx.total,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
