import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../session/application/session_controller.dart';
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
    final hasStockIssues = hasSelectedMachine
        ? cart.items.values.any((it) => it.quantity > it.product.stock)
        : true;

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
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
                    onPressed: () => context.push('/app/products'),
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
                          Icon(
                            Icons.location_on_outlined,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mesin',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  session.selectedMachineName ??
                                      'Pilih mesin sebelum checkout',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight:
                                            session.selectedMachineName != null
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: scheme.primary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...cart.items.values.map((item) {
                  final stock = hasSelectedMachine ? item.product.stock : null;
                  final isOverStock = stock != null && item.quantity > stock;
                  final maxQty = stock == null ? 99 : (stock <= 0 ? 1 : stock);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RoundedCard(
                      child: Row(
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
                                          .read(cartControllerProvider.notifier)
                                          .remove(item.product.id),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                                MoneyText(
                                  item.product.price,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                                if (stock != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    isOverStock
                                        ? 'Sisa stok: $stock (kurangi jumlah)'
                                        : 'Sisa stok: $stock',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: isOverStock
                                              ? scheme.error
                                              : scheme.onSurfaceVariant,
                                          fontWeight: isOverStock
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                        ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    QuantityStepper(
                                      value: item.quantity,
                                      min: 1,
                                      max: maxQty,
                                      onChanged: (v) => ref
                                          .read(cartControllerProvider.notifier)
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
                    ),
                  );
                }),
                const SizedBox(height: 12),
                RoundedCard(
                  child: Column(
                    children: [
                      _Line(label: 'Subtotal', value: cart.subtotal),
                      const SizedBox(height: 8),
                      _Line(label: 'Biaya layanan', value: cart.serviceFee),
                      const SizedBox(height: 8),
                      _Line(label: 'Pajak (11%)', value: cart.tax),
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
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const Spacer(),
        MoneyText(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
