import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../inventory/application/inventory_controller.dart';
import '../../session/application/session_controller.dart';
import '../data/product_repository.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/rounded_card.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productListProvider);
    final session = ref.watch(sessionControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: products.when(
        data: (items) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: items.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return RoundedCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: scheme.secondary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: scheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected machine',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session.selectedMachineName ??
                                'Not selected (stock info hidden)',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/app/map'),
                      child: const Text('Change'),
                    ),
                  ],
                ),
              );
            }

            final p = items[index - 1];
            final machineId = session.selectedMachineId;
            final stock = machineId == null
                ? null
                : ref.watch(stockForSelectedMachineProvider(p.id));
            final isOutOfStock = (stock ?? 1) <= 0;

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.push('/app/products/${p.id}'),
              child: RoundedCard(
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.local_cafe_outlined,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.subtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              MoneyText(
                                p.price,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const Spacer(),
                              Text(
                                stock == null
                                    ? 'Stock: -'
                                    : (isOutOfStock
                                          ? 'Out of stock'
                                          : 'Stock: $stock'),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: stock == null
                                          ? scheme.onSurfaceVariant
                                          : (isOutOfStock
                                                ? scheme.error
                                                : scheme.onSurfaceVariant),
                                      fontWeight: isOutOfStock
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                  ],
                ),
              ),
            );
          },
        ),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
