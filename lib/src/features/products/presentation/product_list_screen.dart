import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../cart/application/cart_controller.dart';
import '../../inventory/application/inventory_controller.dart';
import '../../session/application/session_controller.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/rounded_card.dart';
import '../data/product_repository.dart';
import '../domain/product.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String? _lastInventorySyncKey;

  Future<void> _syncInventoryFromProducts({
    required String machineId,
    required List<Product> items,
  }) async {
    final key =
        '$machineId:${items.length}:${items.map((e) => e.id).join(',')}';
    if (_lastInventorySyncKey == key) return;
    _lastInventorySyncKey = key;

    final inventory = ref.read(inventoryControllerProvider.notifier);
    for (final p in items) {
      final stock = p.stockForMachine(machineId);
      await inventory.setStock(
        machineId: machineId,
        productId: p.id,
        stock: stock,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final selectedMachineId = session.selectedMachineId;
    final selectedMachineName = session.selectedMachineName;
    final hasSelectedMachine = selectedMachineId != null;
    final scheme = Theme.of(context).colorScheme;

    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        actions: [
          IconButton(
            tooltip: 'Keranjang',
            onPressed: () => context.go('/app/cart'),
            icon: Badge(
              isLabelVisible: cart.itemCount > 0,
              label: Text('${cart.itemCount}'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: scheme.error,
                  size: 44,
                ),
                const SizedBox(height: 10),
                Text('Gagal memuat produk.\n$e', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(productListProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (hasSelectedMachine) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _syncInventoryFromProducts(
                machineId: selectedMachineId!,
                items: items,
              );
            });
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productListProvider);
              await ref.read(productListProvider.future);
            },
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                cart.items.isEmpty ? 24 : 100,
              ),
              itemCount: items.isEmpty ? 2 : items.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RoundedCard(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () =>
                            context.push('/app/map?navigateTo=products'),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: scheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.storefront,
                                  color: scheme.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hasSelectedMachine
                                          ? 'Mesin Terpilih'
                                          : 'Pilih Mesin Terlebih Dahulu',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      selectedMachineName ??
                                          'Tap untuk memilih mesin',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.edit_outlined, color: scheme.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada produk',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                final p = items[index - 1];
                final stock = hasSelectedMachine
                    ? p.stockForMachine(selectedMachineId!)
                    : 0;
                final isOutOfStock = hasSelectedMachine && stock <= 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Opacity(
                    opacity: hasSelectedMachine ? 1.0 : 0.60,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: hasSelectedMachine
                          ? () => context.push('/app/products/${p.id}')
                          : null,
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p.benefits,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      MoneyText(
                                        p.price,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const Spacer(),
                                      if (hasSelectedMachine)
                                        Text(
                                          isOutOfStock
                                              ? 'Stok habis'
                                              : 'Stok: $stock',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: isOutOfStock
                                                    ? scheme.error
                                                    : scheme.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
