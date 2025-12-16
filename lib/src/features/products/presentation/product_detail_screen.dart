import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/application/cart_controller.dart';
import '../../inventory/application/inventory_controller.dart';
import '../../session/application/session_controller.dart';
import '../data/product_repository.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/quantity_stepper.dart';
import '../../../shared/widgets/rounded_card.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));
    final session = ref.watch(sessionControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: productAsync.when(
        data: (p) {
          if (p == null) return const Center(child: Text('Product not found'));

          final machineId = session.selectedMachineId;
          final stock = machineId == null
              ? null
              : ref.watch(stockForSelectedMachineProvider(p.id));
          final isOutOfStock = stock != null && stock <= 0;
          final maxQty = stock == null ? 99 : (stock <= 0 ? 1 : stock);
          final addDisabled = machineId == null || isOutOfStock;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              RoundedCard(
                padding: const EdgeInsets.all(0),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.local_cafe_outlined,
                    color: scheme.primary,
                    size: 54,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                p.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p.subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              MoneyText(
                p.price,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              RoundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Machine & stock',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            session.selectedMachineName ??
                                'Not selected (choose a machine first)',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stock == null
                          ? 'Stock: -'
                          : (isOutOfStock ? 'Out of stock' : 'Stock: $stock'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: stock == null
                            ? scheme.onSurfaceVariant
                            : (isOutOfStock ? scheme.error : scheme.primary),
                        fontWeight: isOutOfStock
                            ? FontWeight.w800
                            : FontWeight.w700,
                      ),
                    ),
                    const Divider(height: 22),
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Quantity',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        QuantityStepper(
                          value: _qty,
                          max: maxQty,
                          onChanged: (v) => setState(() => _qty = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: productAsync.maybeWhen(
          data: (p) {
            if (p == null) return const SizedBox.shrink();

            final machineId = session.selectedMachineId;
            final stock = machineId == null
                ? null
                : ref.watch(stockForSelectedMachineProvider(p.id));
            final isOutOfStock = stock != null && stock <= 0;
            final addDisabled = machineId == null || isOutOfStock;

            return FilledButton(
              onPressed: addDisabled
                  ? null
                  : () {
                      ref
                          .read(cartControllerProvider.notifier)
                          .add(p, quantity: _qty);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart')),
                      );
                    },
              child: const Text('Add to cart'),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
