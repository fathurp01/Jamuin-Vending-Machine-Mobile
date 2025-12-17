import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/data/product_repository.dart';
import '../../session/application/session_controller.dart';
import '../../../shared/widgets/rounded_card.dart';

class AdminStockScreen extends ConsumerStatefulWidget {
  const AdminStockScreen({super.key});

  @override
  ConsumerState<AdminStockScreen> createState() => _AdminStockScreenState();
}

class _AdminStockScreenState extends ConsumerState<AdminStockScreen> {
  final Map<String, int> _pendingStock = {};

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

    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Stock'),
        actions: [
          IconButton(
            tooltip: 'Reset perubahan',
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Reset perubahan?'),
                    content: const Text(
                      'Ini hanya menghapus perubahan stok yang belum disimpan.',
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
              if (!mounted) return;
              setState(_pendingStock.clear);
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
                  'Stok Produk (Global)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Menggunakan endpoint PATCH /products/:id (field stok).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => RoundedCard(
              child: Text(
                'Gagal memuat produk.\n$e',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
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

              return Column(
                children: [
                  for (final p in products) ...[
                    _GlobalStockRow(
                      productId: p.id,
                      productName: p.name,
                      currentStock: p.stock,
                      pendingStock: _pendingStock[p.id],
                      onSetPending: (v) =>
                          setState(() => _pendingStock[p.id] = v),
                      onSave: () async {
                        final nextStock = _pendingStock[p.id] ?? p.stock;
                        final repo = ref.read(productRepositoryProvider);
                        final updated = await repo.updateStock(
                          id: p.id,
                          stock: nextStock,
                        );

                        if (!context.mounted) return;
                        if (updated == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal menyimpan stok.'),
                            ),
                          );
                          return;
                        }

                        ref.invalidate(productListProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Stok berhasil diperbarui.'),
                          ),
                        );
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

class _GlobalStockRow extends StatelessWidget {
  const _GlobalStockRow({
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
