import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../cart/application/cart_controller.dart';
import '../../products/data/product_repository.dart';
import '../../session/application/session_controller.dart';
import '../../session/application/session_persistence_providers.dart';
import '../../../shared/widgets/rounded_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/money_text.dart';
import '../../../core/config/backend_config.dart';

String? _resolveImageUrl(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final v = raw.trim();
  if (v.startsWith('http://') || v.startsWith('https://')) return v;
  return '${BackendConfig.baseUrl}/$v';
}

Widget _buildProductImage(String? imageUrl, Color primaryColor) {
  final url = _resolveImageUrl(imageUrl);
  if (url == null) {
    return Icon(
      Icons.local_cafe_outlined,
      color: primaryColor,
      size: 64,
    );
  }
  return LayoutBuilder(
    builder: (context, constraints) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          url,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.local_cafe_outlined,
            color: primaryColor,
            size: 64,
          ),
        ),
      );
    },
  );
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final cart = ref.watch(cartControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jamuin'),
        actions: [
          IconButton(
            tooltip: 'Tentang',
            onPressed: () => context.push('/app/about'),
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            tooltip: 'Keranjang',
            onPressed: () => context.go('/app/cart'),
            icon: Badge(
              isLabelVisible: cart.itemCount > 0,
              label: Text('${cart.itemCount}'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          IconButton(
            tooltip: session.isAuthenticated ? 'Logout' : 'Login',
            onPressed: () async {
              if (!session.isAuthenticated) {
                context.push('/auth/login');
                return;
              }

              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (ok == true && context.mounted) {
                final repo = ref.read(sessionRepositoryProvider);
                await repo.clear();
                ref.read(sessionControllerProvider.notifier).logout();
                if (context.mounted) context.go('/auth/login');
              }
            },
            icon: Icon(session.isAuthenticated ? Icons.logout : Icons.login),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productListProvider);
          await ref.read(productListProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _BannerCarousel(),
            const SizedBox(height: 14),
            RoundedCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Poin',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Coming Soon',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fitur poin akan hadir di update berikutnya.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.stars_rounded, color: scheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    icon: Icons.map_outlined,
                    title: 'Cari Mesin',
                    subtitle: session.selectedMachineName ?? 'Pilih terdekat',
                    onTap: () => context.push('/app/map?navigateTo=products'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionTile(
                    icon: Icons.local_drink_outlined,
                    title: 'Lihat Produk',
                    subtitle: 'Minuman & lainnya',
                    onTap: () => context.go('/app/products'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.psychology_outlined,
              title: 'Konsultasi AI',
              subtitle: 'Rekomendasi jamu sesuai kebutuhan',
              onTap: () => context.go('/app/expert'),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.receipt_long_outlined,
              title: 'Riwayat Transaksi',
              subtitle: 'Menunggu / Berhasil / Gagal',
              onTap: () => context.push('/app/history'),
            ),
            const SizedBox(height: 18),
            SectionHeader(
              title: 'Populer',
              trailing: TextButton(
                onPressed: () => context.go('/app/products'),
                child: const Text('Lihat semua'),
              ),
            ),
            const SizedBox(height: 10),
            Consumer(
              builder: (context, ref, _) {
                final products = ref.watch(productListProvider);
                return products.when(
                  data: (items) => SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final p = items[index];
                        return SizedBox(
                          width: 180,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => context.push('/app/products/${p.id}'),
                            child: RoundedCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: scheme.primary.withValues(
                                        alpha: 0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: _buildProductImage(
                                      p.image,
                                      scheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p.benefits,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: scheme.onSurface.withOpacity(0.7),
                                        ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: MoneyText(
                                          p.price,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: scheme.primary,
                                              ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: scheme.primary,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  error: (e, _) => Text('Gagal memuat: $e'),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            RoundedCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Siap pesan?',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pilih mesin, tambah item, lalu checkout dengan cepat.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () => context.go('/app/products'),
                    child: const Text('Mulai'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              session.role == UserRole.admin ? 'Mode admin' : 'Mode pelanggan',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurface.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: RoundedCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.secondary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: scheme.secondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final items = <({String title, String subtitle, IconData icon})>[
      (
        title: 'Stok sesuai mesin',
        subtitle: 'Pilih mesin untuk lihat ketersediaan',
        icon: Icons.local_offer_outlined,
      ),
      (
        title: 'Pilih mesin terdekat',
        subtitle: 'Biar ambil pesanan lebih cepat',
        icon: Icons.location_on_outlined,
      ),
      (
        title: 'Bayar & ambil di mesin',
        subtitle: 'Checkout lalu ambil langsung',
        icon: Icons.stars_outlined,
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (v) => setState(() => _index = v),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final it = items[i];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: RoundedCard(
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(it.icon, color: scheme.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              it.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              it.subtitle,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: scheme.onSurface.withOpacity(0.7)),
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
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            items.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _index
                    ? scheme.primary
                    : scheme.onSurface.withOpacity(0.25),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
