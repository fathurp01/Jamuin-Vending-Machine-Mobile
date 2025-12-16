import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../cart/application/cart_controller.dart';
import '../../inventory/application/inventory_controller.dart';
import '../../session/application/session_controller.dart';
import '../application/checkout_controller.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/rounded_card.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _placing = false;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final inventory = ref.watch(inventoryControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    final machineId = session.selectedMachineId;
    final hasSelectedMachine = machineId != null;
    final stockOk = hasSelectedMachine
        ? cart.items.values.every((it) {
            final stock = inventory.stockFor(
              machineId: machineId,
              productId: it.product.id,
            );
            return it.quantity <= stock;
          })
        : false;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          RoundedCard(
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
                    Icons.location_on_outlined,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vending machine',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.selectedMachineName ?? 'Not selected',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
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
          ),
          const SizedBox(height: 12),
          if (hasSelectedMachine && !stockOk)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RoundedCard(
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_outlined, color: scheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Some items exceed available stock for this machine.\nPlease adjust quantities in your cart.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/app/cart'),
                      child: const Text('Cart'),
                    ),
                  ],
                ),
              ),
            ),
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order summary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                ...cart.items.values.map(
                  (it) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('${it.quantity}× ${it.product.name}'),
                        ),
                        MoneyText(it.lineTotal),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 22),
                _Line(label: 'Subtotal', value: cart.subtotal),
                const SizedBox(height: 8),
                _Line(label: 'Service fee', value: cart.serviceFee),
                const SizedBox(height: 8),
                _Line(label: 'Tax (11%)', value: cart.tax),
                const Divider(height: 22),
                Row(
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    MoneyText(
                      cart.total,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          RoundedCard(
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
                    Icons.credit_card_outlined,
                    color: scheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Card / QR (placeholder)',
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
          const SizedBox(height: 8),
          Text(
            'Tip: For demo, order status updates automatically after checkout.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: FilledButton(
          onPressed: (_placing || !stockOk)
              ? null
              : () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final router = GoRouter.of(context);

                  if (session.selectedMachineName == null) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Please select a vending machine first.'),
                      ),
                    );
                    return;
                  }

                  setState(() => _placing = true);
                  final id = await ref
                      .read(checkoutControllerProvider.notifier)
                      .placeOrder();
                  if (!mounted) return;
                  setState(() => _placing = false);

                  if (id == null) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Cart is empty.')),
                    );
                    return;
                  }

                  if (!mounted) return;
                  router.go('/app/tx/$id');
                },
          child: _placing
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Place order'),
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
