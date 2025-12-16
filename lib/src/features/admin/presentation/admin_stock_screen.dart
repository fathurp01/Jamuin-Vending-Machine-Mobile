import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inventory/application/inventory_controller.dart';
import '../../map/presentation/machine_providers.dart';
import '../../products/data/product_repository.dart';
import '../../session/application/session_controller.dart';
import '../../../shared/widgets/rounded_card.dart';

class AdminStockScreen extends ConsumerStatefulWidget {
  const AdminStockScreen({super.key});

  @override
  ConsumerState<AdminStockScreen> createState() => _AdminStockScreenState();
}

class _AdminStockScreenState extends ConsumerState<AdminStockScreen> {
  String? _machineId;

  @override
  void initState() {
    super.initState();
    final machines = ref.read(machinesProvider);
    if (machines.isNotEmpty) {
      _machineId = machines.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    if (session.role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manage Stock')),
        body: Center(
          child: RoundedCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, color: scheme.onSurfaceVariant),
                const SizedBox(height: 10),
                Text(
                  'Access denied',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'This area is available for admins only.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final machines = ref.watch(machinesProvider);
    final effectiveMachineId =
        _machineId ?? (machines.isNotEmpty ? machines.first.id : null);

    final productsAsync = ref.watch(productListProvider);
    final inventory = ref.watch(inventoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Stock'),
        actions: [
          IconButton(
            tooltip: 'Reset defaults',
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Reset stock?'),
                    content: const Text(
                      'Restore inventory for all machines to default values.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Reset'),
                      ),
                    ],
                  );
                },
              );

              if (ok != true) return;
              await ref
                  .read(inventoryControllerProvider.notifier)
                  .resetToDefaults();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Machine', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                if (machines.isEmpty)
                  Text(
                    'No machines available.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: effectiveMachineId,
                    decoration: const InputDecoration(
                      labelText: 'Select machine',
                    ),
                    items: [
                      for (final m in machines)
                        DropdownMenuItem(value: m.id, child: Text(m.name)),
                    ],
                    onChanged: (v) => setState(() => _machineId = v),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          productsAsync.when(
            data: (products) {
              if (effectiveMachineId == null) {
                return RoundedCard(
                  child: Text(
                    'Select a machine to edit stock.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  for (final p in products) ...[
                    _StockRow(
                      machineId: effectiveMachineId,
                      productId: p.id,
                      productName: p.name,
                      stock: inventory.stockFor(
                        machineId: effectiveMachineId,
                        productId: p.id,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => RoundedCard(
              child: Text(
                'Failed to load products.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockRow extends ConsumerWidget {
  const _StockRow({
    required this.machineId,
    required this.productId,
    required this.productName,
    required this.stock,
  });

  final String machineId;
  final String productId;
  final String productName;
  final int stock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return RoundedCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Stock: $stock',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Decrease',
            onPressed: stock <= 0
                ? null
                : () => ref
                      .read(inventoryControllerProvider.notifier)
                      .addStock(
                        machineId: machineId,
                        productId: productId,
                        delta: -1,
                      ),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          IconButton(
            tooltip: 'Increase',
            onPressed: () => ref
                .read(inventoryControllerProvider.notifier)
                .addStock(machineId: machineId, productId: productId, delta: 1),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
