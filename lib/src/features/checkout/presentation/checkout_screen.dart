import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../cart/application/cart_controller.dart';
import '../../session/application/session_controller.dart';
import '../application/checkout_controller.dart';
import '../../transactions/domain/transaction_record.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/rounded_card.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _placing = false;

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionControllerProvider);
    _nameCtrl.text = (session.displayName ?? '').trim();
    _emailCtrl.text = (session.email ?? '').trim();
    _phoneCtrl.text = (session.phone ?? '').trim();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
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
    final hasSingleItem = cart.items.length == 1;
    final stockOk = hasSingleItem
        ? cart.items.values.single.quantity <=
              cart.items.values.single.product.stock
        : false;

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
                          'Vending machine',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.selectedMachineName ?? 'Not selected',
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
            ),
            const SizedBox(height: 12),
            RoundedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer info',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'Name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'Email is required';
                      final emailOk = RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(value);
                      if (!emailOk) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'Phone is required';
                      final digitsOnly = RegExp(r'^\+?[0-9]{8,15}$');
                      if (!digitsOnly.hasMatch(value)) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      prefixIcon: Icon(Icons.sticky_note_2_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (!hasSingleItem)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RoundedCard(
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: scheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Checkout currently supports 1 product per transaction. Please adjust your cart.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/app/cart'),
                        child: const Text('Cart'),
                      ),
                    ],
                  ),
                ),
              )
            else if (hasSelectedMachine && !stockOk)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RoundedCard(
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_outlined, color: scheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Quantity exceeds available product stock.\nPlease adjust quantities in your cart.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
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
                          'Payment',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Midtrans Snap (WebView)',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'After completing payment, tap “Check status”.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: FilledButton(
          onPressed:
              (_placing || !hasSelectedMachine || !hasSingleItem || !stockOk)
              ? null
              : () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final router = GoRouter.of(context);

                  if (!_formKey.currentState!.validate()) return;

                  if (session.selectedMachineName == null) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Please select a vending machine first.'),
                      ),
                    );
                    return;
                  }

                  setState(() => _placing = true);
                  final result = await ref
                      .read(checkoutControllerProvider.notifier)
                      .placeOrder(
                        customer: CustomerInfo(
                          name: _nameCtrl.text.trim(),
                          phone: _phoneCtrl.text.trim(),
                          notes: _notesCtrl.text.trim().isEmpty
                              ? null
                              : _notesCtrl.text.trim(),
                        ),
                      );
                  if (!mounted) return;
                  setState(() => _placing = false);

                  final orderId = result.orderId;
                  final snapUrl = result.snapUrl;
                  if (orderId == null || snapUrl == null) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(result.error ?? 'Checkout failed.'),
                      ),
                    );
                    return;
                  }

                  if (!mounted) return;
                  router.go('/app/payment/$orderId', extra: snapUrl);
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
