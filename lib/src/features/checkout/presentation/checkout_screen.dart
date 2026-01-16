import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../cart/application/cart_controller.dart';
import '../../session/application/session_controller.dart';
import '../../inventory/application/inventory_controller.dart';
import '../application/checkout_controller.dart';
import '../domain/payment_flow.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/rounded_card.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();

  bool _placing = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    final machineId = session.selectedMachineId;
    final hasSelectedMachine = machineId != null;

    // Check stock dengan inventory per-machine
    bool stockOk = hasSelectedMachine;
    if (hasSelectedMachine) {
      for (final item in cart.items.values) {
        final stock = ref.watch(
          stockForSelectedMachineProvider(item.product.id),
        );
        if (item.quantity > stock) {
          stockOk = false;
          break;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
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
                          'Mesin vending',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.selectedMachineName ?? 'Belum dipilih',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (!session.isAuthenticated)
              RoundedCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Login diperlukan',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Silakan login terlebih dahulu untuk melakukan transaksi',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.go('/auth/login'),
                      icon: const Icon(Icons.login),
                      label: const Text('Login'),
                    ),
                  ],
                ),
              )
            else
              RoundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data pelanggan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.person_outline, color: scheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nama',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                session.displayName ?? '-',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, color: scheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                session.email ?? '-',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, color: scheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Telepon',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                session.phone ?? '-',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                          'Jumlah melebihi stok yang tersedia.\nSilakan sesuaikan jumlah di keranjang.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/app/cart'),
                        child: const Text('Keranjang'),
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
                    'Ringkasan pesanan',
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
                          'Pembayaran',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Midtrans Snap (WebView)',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Setelah menyelesaikan pembayaran, tekan “Cek status”.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: FilledButton(
          onPressed:
              (_placing ||
                  !session.isAuthenticated ||
                  !hasSelectedMachine ||
                  cart.subtotal == 0 ||
                  !stockOk)
              ? null
              : () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final router = GoRouter.of(context);

                  if (!session.isAuthenticated) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Silakan login terlebih dahulu.',
                        ),
                      ),
                    );
                    context.go('/auth/login');
                    return;
                  }

                  if (!_formKey.currentState!.validate()) return;

                  if (session.selectedMachineName == null) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Silakan pilih mesin vending terlebih dahulu.',
                        ),
                      ),
                    );
                    return;
                  }

                  setState(() => _placing = true);
                  final result = await ref
                      .read(checkoutControllerProvider.notifier)
                      .placeOrder();
                  if (!mounted) return;
                  setState(() => _placing = false);

                  final first = result.first;
                  if (first == null) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(result.error ?? 'Checkout gagal.'),
                      ),
                    );
                    return;
                  }

                  if (!mounted) return;
                  router.go(
                    '/app/payment/${first.orderId}',
                    extra: PaymentFlowArgs(
                      snapUrl: first.snapUrl,
                      remaining: result.remaining,
                    ),
                  );
                },
          child: _placing
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Buat pesanan'),
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
