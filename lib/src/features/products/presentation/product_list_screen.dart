import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/product_repository.dart';
import '../../cart/application/cart_controller.dart';
import '../../session/application/session_controller.dart';
import '../../inventory/application/inventory_controller.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/rounded_card.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    // Sync inventory when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncInventory();
    });
  }

  void _syncInventory() {
    final session = ref.read(sessionControllerProvider);
    final selectedMachineId = session.selectedMachineId;

    if (selectedMachineId != null) {
      // Load products untuk sync inventory
      ref
          .read(productsByMachineProvider(selectedMachineId).future)
          .then((products) {
            final inventory = ref.read(inventoryControllerProvider.notifier);
            for (final product in products) {
              // Sync stock dari API response ke inventory
              inventory.setStock(
                machineId: selectedMachineId,
                productId: product.id,
                stock: product.stock,
              );
            }
          })
          .catchError((_) {
            // Silently fail
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final selectedMachineId = session.selectedMachineId;
    final selectedMachineName = session.selectedMachineName;
    final scheme = Theme.of(context).colorScheme;

    // Fetch products berdasarkan selected machine
    final productsAsync = selectedMachineId != null
        ? ref.watch(productsByMachineProvider(selectedMachineId))
        : null;

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
      body: selectedMachineId == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.store, size: 64, color: scheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'Pilih Mesin Terlebih Dahulu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Silakan pilih mesin vending untuk melihat produk yang tersedia',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/app/map'),
                    icon: const Icon(Icons.location_on),
                    label: const Text('Pilih Mesin'),
                  ),
                ],
              ),
            )
          : productsAsync == null
          ? const Center(child: CircularProgressIndicator())
          : productsAsync.when(
              data: (items) => Column(
                children: [
                  // Card pilih mesin di atas
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: RoundedCard(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => context.push('/app/map'),
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
                                      'Mesin Terpilih',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      selectedMachineName ?? 'Pilih mesin',
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
                  ),
                  // Product list
                  Expanded(
                    child: items.isEmpty
                        ? Center(
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
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Mesin ini belum memiliki produk',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              cart.items.isEmpty ? 24 : 100,
                            ),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final p = items[index];
                              // Stock sudah ada di p.stock dari API response
                              final stock = p.stock;
                              final isOutOfStock = stock <= 0;

                              return InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () =>
                                    context.push('/app/products/${p.id}'),
                                child: RoundedCard(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: scheme.primary.withValues(
                                            alpha: 0.10,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.local_cafe_outlined,
                                          color: scheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        scheme.onSurfaceVariant,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                MoneyText(p.price),
                                                const Spacer(),
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
                                                            : scheme
                                                                  .onSurfaceVariant,
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
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: scheme.error),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat produk',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: FilledButton(
                onPressed: () => context.go('/app/cart'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Badge(
                      isLabelVisible: cart.itemCount > 0,
                      label: Text('${cart.itemCount}'),
                      child: const Icon(Icons.shopping_bag_outlined),
                    ),
                    const SizedBox(width: 12),
                    const Text('Bayar Sekarang'),
                  ],
                ),
              ),
            ),
    );
  }
}
