import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/application/cart_controller.dart';
import '../../map/presentation/machine_providers.dart';
import '../../session/application/session_controller.dart';
import '../../inventory/application/inventory_controller.dart';
import '../data/product_repository.dart';
import '../../../core/config/backend_config.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../shared/widgets/quantity_stepper.dart';
import '../../../shared/widgets/rounded_card.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _qty = 1;

  String? _resolveImageUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final v = raw.trim();
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    return '${BackendConfig.baseUrl}/$v';
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));
    final session = ref.watch(sessionControllerProvider);
    final selectedMachineId = session.selectedMachineId;
    final machinesAsync = ref.watch(machinesProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: productAsync.when(
        data: (p) {
          if (p == null) return const Center(child: Text('Product not found'));

          if (selectedMachineId != null) {
            final remote = p.stockForMachine(selectedMachineId);
            final local = ref.watch(
              stockForSelectedMachineProvider(widget.productId),
            );
            if (remote != local) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                ref
                    .read(inventoryControllerProvider.notifier)
                    .setStock(
                      machineId: selectedMachineId,
                      productId: widget.productId,
                      stock: remote,
                    );
              });
            }
          }

          // Get stock dari selected machine
          final stock = selectedMachineId != null
              ? ref.watch(stockForSelectedMachineProvider(widget.productId))
              : p.stockForMachine(selectedMachineId ?? '0');
          final isOutOfStock = stock <= 0;
          final maxQty = stock <= 0 ? 1 : stock;
          final imageUrl = _resolveImageUrl(p.image);

          String? lookupMachineName(String machineId) {
            return machinesAsync.maybeWhen(
              data: (machines) {
                for (final m in machines) {
                  if (m.id == machineId) return m.name;
                }
                return null;
              },
              orElse: () => null,
            );
          }

          final selectedMachineName = (session.selectedMachineName ?? '')
              .trim();
          final selectedMachineLabel = selectedMachineId == null
              ? null
              : (selectedMachineName.isNotEmpty
                    ? 'Mesin $selectedMachineName'
                    : 'Mesin #$selectedMachineId');

          String? recommendedMachineLabel;
          if (selectedMachineId != null && isOutOfStock) {
            final selectedMachineIdNum = int.tryParse(selectedMachineId);
            int? bestMachineId;
            int bestStock = -1;
            for (final mp in p.machineProducts) {
              if (mp.stok <= 0) continue;
              if (selectedMachineIdNum != null &&
                  mp.machineId == selectedMachineIdNum) {
                continue;
              }
              if (mp.stok > bestStock) {
                bestStock = mp.stok;
                bestMachineId = mp.machineId;
              }
            }

            if (bestMachineId != null) {
              final bestMachineIdStr = bestMachineId.toString();
              final bestName = (lookupMachineName(bestMachineIdStr) ?? '')
                  .trim();
              recommendedMachineLabel = bestName.isNotEmpty
                  ? 'Mesin $bestName'
                  : 'Mesin #$bestMachineIdStr';
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              RoundedCard(
                padding: const EdgeInsets.all(0),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: imageUrl == null
                      ? Icon(
                          Icons.local_drink_outlined,
                          color: scheme.primary,
                          size: 80,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.local_drink_outlined,
                              color: scheme.primary,
                              size: 80,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                p.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const SizedBox(height: 12),
              MoneyText(
                p.price,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              RoundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedMachineId == null
                          ? 'Stok (pilih mesin terlebih dahulu)'
                          : 'Stok',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedMachineId == null
                          ? 'Pilih mesin dari halaman peta'
                          : isOutOfStock
                          ? (recommendedMachineLabel == null
                                ? 'Stok habis'
                                : 'Stok habis - Stok Tersedia di $recommendedMachineLabel')
                          : '$stock - $selectedMachineLabel',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: selectedMachineId == null
                            ? scheme.onSurfaceVariant
                            : isOutOfStock
                            ? scheme.error
                            : scheme.primary,
                        fontWeight: isOutOfStock
                            ? FontWeight.w800
                            : FontWeight.w700,
                      ),
                    ),
                    const Divider(height: 22),
                    Text(
                      'Deskripsi',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Manfaat',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.benefits,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Jumlah',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        QuantityStepper(
                          value: _qty,
                          max: maxQty,
                          onChanged: (v) => setState(() => _qty = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: productAsync.maybeWhen(
          data: (p) {
            if (p == null) return const SizedBox.shrink();

            final stock = selectedMachineId != null
                ? ref.watch(stockForSelectedMachineProvider(widget.productId))
                : 0;
            final isOutOfStock = stock <= 0;
            final noMachineSelected = selectedMachineId == null;

            return FilledButton(
              onPressed: (isOutOfStock || noMachineSelected)
                  ? null
                  : () {
                      ref
                          .read(cartControllerProvider.notifier)
                          .add(p, quantity: _qty);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ditambahkan ke keranjang'),
                        ),
                      );
                    },
              child: Text(
                noMachineSelected
                    ? 'Pilih mesin terlebih dahulu'
                    : 'Tambah ke keranjang',
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
