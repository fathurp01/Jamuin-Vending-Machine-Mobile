import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../map/presentation/machine_models.dart';
import '../../map/presentation/machine_providers.dart';
import '../../products/data/product_repository.dart';
import '../../session/application/session_controller.dart';
import '../../../shared/widgets/rounded_card.dart';

final _allMachinesProvider = FutureProvider<List<VendingMachine>>((ref) async {
  final repo = ref.read(machinesRepositoryProvider);
  return repo.listAll();
});

class AdminMachineStockScreen extends ConsumerStatefulWidget {
  const AdminMachineStockScreen({super.key});

  @override
  ConsumerState<AdminMachineStockScreen> createState() =>
      _AdminMachineStockScreenState();
}

class _AdminMachineStockScreenState
    extends ConsumerState<AdminMachineStockScreen> {
  String? _selectedMachineId;
  final Map<String, int> _pendingStock = {};

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    if (session.role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kelola Stok Per Mesin')),
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

    final machinesAsync = ref.watch(_allMachinesProvider);
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Stok Per Mesin'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              ref.invalidate(_allMachinesProvider);
              ref.invalidate(productListProvider);
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
                Text(
                  'Pilih mesin',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                machinesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, __) => Text(
                    'Gagal memuat mesin.\n$e',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  data: (machines) {
                    if (machines.isEmpty) {
                      return Text(
                        'Belum ada mesin.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      );
                    }

                    final items = machines
                        .map(
                          (m) => DropdownMenuItem<String>(
                            value: m.id,
                            child: Text('${m.name} (${m.code})'),
                          ),
                        )
                        .toList(growable: false);

                    return DropdownButtonFormField<String>(
                      value: _selectedMachineId,
                      hint: const Text('Pilih mesin...'),
                      items: items,
                      onChanged: (v) {
                        setState(() {
                          _selectedMachineId = v;
                          _pendingStock.clear();
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedMachineId == null)
            RoundedCard(
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pilih mesin terlebih dahulu untuk mengatur stok produk.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => RoundedCard(
                child: Text(
                  'Gagal memuat produk.\n$e',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return RoundedCard(
                    child: Text(
                      'Belum ada produk.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                final machineId = _selectedMachineId!;

                return Column(
                  children: [
                    for (final p in products) ...[
                      _MachineStockRow(
                        productId: p.id,
                        productName: p.name,
                        currentStock: p.stockForMachine(machineId),
                        pendingStock: _pendingStock[p.id],
                        onSetPending: (v) =>
                            setState(() => _pendingStock[p.id] = v),
                        onSave: () async {
                          final nextStock =
                              _pendingStock[p.id] ??
                              p.stockForMachine(machineId);
                          try {
                            final repo = ref.read(productRepositoryProvider);
                            await repo.setMachineStock(
                              productId: p.id,
                              machineId: machineId,
                              stock: nextStock,
                            );

                            if (!context.mounted) return;
                            ref.invalidate(productListProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Stok per-mesin berhasil diperbarui.',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal menyimpan stok: $e'),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MachineStockRow extends StatelessWidget {
  const _MachineStockRow({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.pendingStock,
    required this.onSetPending,
    required this.onSave,
  });

  final String productId;
  final String productName;
  final int currentStock;
  final int? pendingStock;
  final ValueChanged<int> onSetPending;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final value = pendingStock ?? currentStock;

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
                  'Stok saat ini: $currentStock',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stok baru: $value',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: 'Kurangi',
                onPressed: value <= 0 ? null : () => onSetPending(value - 1),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              IconButton(
                tooltip: 'Tambah',
                onPressed: () => onSetPending(value + 1),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(width: 6),
          FilledButton(onPressed: onSave, child: const Text('Simpan')),
        ],
      ),
    );
  }
}
