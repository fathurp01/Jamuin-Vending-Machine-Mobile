import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../session/application/session_controller.dart';
import '../../inventory/application/inventory_controller.dart';
import '../application/cart_controller.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/quantity_stepper.dart';
import '../../../shared/widgets/rounded_card.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    final machineId = session.selectedMachineId;
    final hasSelectedMachine = machineId != null;

    // Check stock issues dengan menggunakan inventory per-machine
    bool hasStockIssues = false;
    if (hasSelectedMachine) {
      for (final item in cart.items.values) {
        final stock = ref.watch(
          stockForSelectedMachineProvider(item.product.id),
        );
        if (item.quantity > stock) {
          hasStockIssues = true;
          break;
        }
      }
    } else {
      hasStockIssues = true; // No machine selected
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () {
            final nav = Navigator.of(context);
            if (nav.canPop()) {
              nav.pop();
              return;
            }
            context.go('/app/products');
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 42,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Keranjang kamu kosong',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lihat produk untuk menambahkan item.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () => context.go('/app/products'),
                    child: const Text('Lihat produk'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                RoundedCard(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => context.push('/app/map?navigateTo=cart'),
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
                                  'Mesin terpilih',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  session.selectedMachineName ??
                                      'Belum dipilih (tap untuk pilih)',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
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
                const SizedBox(height: 12),
                ...cart.items.values.map((item) {
                  // Get stock dari selected machine
                  final stock = hasSelectedMachine
                      ? ref.watch(
                          stockForSelectedMachineProvider(item.product.id),
                        )
                      : 0;
                  final isOverStock =
                      hasSelectedMachine && item.quantity > stock;
                  final isOutOfStock = hasSelectedMachine && stock <= 0;
                  final maxQty = !hasSelectedMachine
                      ? 99
                      : (stock < 0 ? 0 : stock);
                  final minQty = (!hasSelectedMachine || isOutOfStock) ? 0 : 1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RoundedCard(
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: scheme.primary.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.local_cafe_outlined,
                                  color: scheme.primary,
                                ),
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
                                            item.product.name,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Hapus',
                                          onPressed: () => ref
                                              .read(
                                                cartControllerProvider.notifier,
                                              )
                                              .remove(item.product.id),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                    MoneyText(
                                      item.product.price,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (!hasSelectedMachine)
                                      Text(
                                        'Pilih mesin untuk cek stok.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      )
                                    else
                                      Text(
                                        isOutOfStock
                                            ? 'Out of stock'
                                            : (isOverStock
                                                  ? 'Sisa stok: $stock (kurangi jumlah)'
                                                  : 'Sisa stok: $stock'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  (isOutOfStock || isOverStock)
                                                  ? scheme.error
                                                  : scheme.onSurfaceVariant,
                                              fontWeight:
                                                  (isOutOfStock || isOverStock)
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                            ),
                                      ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        QuantityStepper(
                                          value: item.quantity,
                                          min: minQty,
                                          max: maxQty,
                                          onChanged: (v) => ref
                                              .read(
                                                cartControllerProvider.notifier,
                                              )
                                              .setQuantity(item.product.id, v),
                                        ),
                                        const Spacer(),
                                        MoneyText(
                                          item.lineTotal,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (isOutOfStock)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerHighest
                                        .withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'OUT OF STOCK',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                RoundedCard(
                  child: Column(
                    children: [
                      _Line(label: 'Subtotal', value: cart.subtotal),
                      const Divider(height: 22),
                      Row(
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const Spacer(),
                          MoneyText(
                            cart.total,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: FilledButton(
                onPressed: hasStockIssues
                    ? null
                    : () {
                        if (!session.isAuthenticated) {
                          context.push(
                            '/auth/login?redirect=${Uri.encodeComponent('/app/cart')}',
                          );
                          return;
                        }
                        context.push('/app/checkout');
                      },
                child: const Text('Checkout'),
              ),
            ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
        ),
        const Spacer(),
        MoneyText(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
        ),
      ],
    );
  }
}
