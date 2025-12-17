import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/product_repository.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/rounded_card.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productListProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: products.when(
        data: (items) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final p = items[index];
            final isOutOfStock = p.stock <= 0;

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
                            p.benefits,
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
                                isOutOfStock
                                    ? 'Out of stock'
                                    : 'Stock: ${p.stock}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isOutOfStock
                                          ? scheme.error
                                          : scheme.onSurfaceVariant,
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
