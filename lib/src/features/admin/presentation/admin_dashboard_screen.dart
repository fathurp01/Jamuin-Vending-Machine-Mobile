import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../session/application/session_controller.dart';
import '../../session/application/session_persistence_providers.dart';
import '../../../shared/widgets/rounded_card.dart';
import '../../../core/networking/dio_provider.dart';

final _machineDashboardProvider = FutureProvider<Map<String, Object?>>((
  ref,
) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get<Map<String, Object?>>('/machines/dashboard');
  return res.data ?? const <String, Object?>{};
});

class _DailyRevenuePoint {
  const _DailyRevenuePoint({required this.day, required this.revenue});

  final DateTime day;
  final int revenue;
}

class _SalesMetrics {
  const _SalesMetrics({
    required this.todayOrders,
    required this.todayRevenue,
    required this.last7DaysRevenue,
  });

  final int todayOrders;
  final int todayRevenue;
  final List<_DailyRevenuePoint> last7DaysRevenue;
}

final _adminSalesMetricsProvider = FutureProvider<_SalesMetrics>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get<List<dynamic>>('/payments/transactions');
  final data = res.data ?? const [];

  int toInt(Object? v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final s = v.trim();
      // Support decimal strings like "12000.00" (from DB decimal columns).
      final asDouble = double.tryParse(s);
      if (asDouble != null) return asDouble.toInt();
      return int.tryParse(s) ?? fallback;
    }
    return fallback;
  }

  DateTime? toDateTime(Object? v) {
    if (v is DateTime) return v;
    if (v is String && v.trim().isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  final now = DateTime.now();
  bool isToday(DateTime? dt) {
    if (dt == null) return false;
    final local = dt.toLocal();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  bool isPaidStatus(String statusRaw) {
    final status = statusRaw.trim().toLowerCase();
    return status == 'success' || status == 'paid' || status == 'settlement';
  }

  DateTime dayOnly(DateTime dt) {
    final local = dt.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  int todayOrders = 0;
  int todayRevenue = 0;

  // Revenue buckets for the last 7 days (including today), in local time.
  final start = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 6));
  final days = List<DateTime>.generate(
    7,
    (i) => start.add(Duration(days: i)),
    growable: false,
  );
  final revenueByDay = <DateTime, int>{for (final d in days) d: 0};

  for (final v in data) {
    if (v is! Map) continue;
    final m = v.cast<String, Object?>();
    final createdAt = toDateTime(m['createdAt']);

    final statusRaw = (m['status'] as String?) ?? '';
    final gross = toInt(m['grossAmount']);

    // Today summary.
    if (isToday(createdAt)) {
      todayOrders += 1;
      if (isPaidStatus(statusRaw)) {
        todayRevenue += gross;
      }
    }

    // Last 7 days revenue.
    if (createdAt != null && isPaidStatus(statusRaw)) {
      final d = dayOnly(createdAt);
      if (revenueByDay.containsKey(d)) {
        revenueByDay[d] = (revenueByDay[d] ?? 0) + gross;
      }
    }
  }

  final points = [
    for (final d in days)
      _DailyRevenuePoint(day: d, revenue: revenueByDay[d] ?? 0),
  ];

  print('📊 Revenue Graph Data:');
  print('   Total transactions: ${data.length}');
  print('   Today orders: $todayOrders');
  print('   Today revenue: Rp $todayRevenue');
  print('   Last 7 days data points: ${points.length}');
  for (final p in points) {
    print('   ${p.day.toString().substring(0, 10)}: Rp ${p.revenue}');
  }

  return _SalesMetrics(
    todayOrders: todayOrders,
    todayRevenue: todayRevenue,
    last7DaysRevenue: points,
  );
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    if (session.role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              final repo = ref.read(sessionRepositoryProvider);
              await repo.clear();
              ref.read(sessionControllerProvider.notifier).logout();
              if (context.mounted) context.go('/auth/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_machineDashboardProvider);
          ref.invalidate(_adminSalesMetricsProvider);
          // Wait for fresh data so the indicator doesn't stop too early.
          await Future.wait([
            ref.read(_machineDashboardProvider.future),
            ref.read(_adminSalesMetricsProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            RoundedCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Operational summary',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Quick view of sales and machine status.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.dashboard_outlined,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, ref, _) {
                final dashAsync = ref.watch(_machineDashboardProvider);
                final salesAsync = ref.watch(_adminSalesMetricsProvider);

                final online = dashAsync.valueOrNull?['online'];
                final maintenance = dashAsync.valueOrNull?['maintenance'];

                final orders = salesAsync.valueOrNull?.todayOrders;
                final revenue = salesAsync.valueOrNull?.todayRevenue;
                final series = salesAsync.valueOrNull?.last7DaysRevenue;

                String fmtRp(int v) {
                  // Simple compact formatting without adding extra dependencies.
                  if (v >= 1000000) {
                    return 'Rp ${(v / 1000000).toStringAsFixed(1)}M';
                  }
                  if (v >= 1000) return 'Rp ${(v / 1000).toStringAsFixed(1)}K';
                  return 'Rp $v';
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            title: 'Orders',
                            value: orders?.toString() ?? '—',
                            icon: Icons.receipt_long_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            title: 'Revenue',
                            value: revenue == null ? '—' : fmtRp(revenue),
                            icon: Icons.payments_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            title: 'Machines Online',
                            value: online?.toString() ?? '—',
                            icon: Icons.wifi_tethering_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            title: 'Maintenance',
                            value: maintenance?.toString() ?? '—',
                            icon: Icons.warning_amber_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RoundedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Grafik revenue (7 hari)',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              if (salesAsync.isLoading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else if (salesAsync.hasError)
                                Icon(Icons.error_outline, size: 16, color: scheme.error),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (salesAsync.isLoading)
                            const Text('Loading...')
                          else if (salesAsync.hasError)
                            Text(
                              'Error: ${salesAsync.error}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: scheme.error),
                            )
                          else if (series != null && series.isNotEmpty)
                            _RevenueBarChart(
                              points: series,
                              formatValue: fmtRp,
                            )
                          else
                            Text(
                              'Tidak ada data',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            RoundedCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin tools',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Terhubung ke backend untuk transaksi & stok.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      FilledButton.icon(
                        onPressed: () => context.go('/app/admin/monitor'),
                        icon: const Icon(
                          Icons.monitor_heart_outlined,
                          size: 18,
                        ),
                        label: const Text('Monitor Machines'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => context.go('/app/admin/add-machine'),
                        child: const Text('Tambah Mesin'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => context.go('/app/admin/machine-stock'),
                        child: const Text('Kelola Stok Per Mesin'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => context.go('/app/admin/stock'),
                        child: const Text('Manage stock (Global)'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => context.go('/app/admin/transactions'),
                        child: const Text('Transactions'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => context.push('/app/about'),
                        child: const Text('About'),
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
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return RoundedCard(
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueBarChart extends StatelessWidget {
  const _RevenueBarChart({required this.points, required this.formatValue});

  final List<_DailyRevenuePoint> points;
  final String Function(int value) formatValue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final maxValue = points.fold<int>(0, (prev, p) {
      if (p.revenue > prev) return p.revenue;
      return prev;
    });

    print('📊 _RevenueBarChart rendering:');
    print('   Points count: ${points.length}');
    print('   Max value: Rp $maxValue');

    // Fixed chart height to keep layout stable.
    const chartHeight = 120.0;

    String fmtDay(DateTime d) {
      // Keep it simple without intl: dd/MM
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      return '$dd/$mm';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart Area
        SizedBox(
          height: chartHeight,
          width: double.infinity,
          child: CustomPaint(
            painter: _LineChartPainter(
              points: points,
              maxValue: maxValue,
              color: scheme.primary,
              surfaceColor: scheme.surface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // X-Axis Labels
        Row(
          children: [
            for (final p in points)
              Expanded(
                child: Text(
                  fmtDay(p.day),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          maxValue == 0
              ? 'Tidak ada transaksi sukses 7 hari terakhir.'
              : 'Puncak: ${formatValue(maxValue)}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.points,
    required this.maxValue,
    required this.color,
    required this.surfaceColor,
  });

  final List<_DailyRevenuePoint> points;
  final int maxValue;
  final Color color;
  final Color surfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final effectiveMax = maxValue <= 0 ? 1 : maxValue;
    final columnWidth = size.width / points.length;

    // Configuration
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.25),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final dotPaintFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final dotPaintBorder = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final fillPath = Path();

    // Calculate Coordinates
    final List<Offset> coordinates = [];
    
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      // Center X in the column
      final x = (i * columnWidth) + (columnWidth / 2);
      
      // Map revenue to height (leaving 15% top padding for aesthetics)
      final t = (p.revenue / effectiveMax).clamp(0.0, 1.0);
      final y = size.height - (t * (size.height * 0.85));

      coordinates.add(Offset(x, y));
    }

    // Build Paths
    if (coordinates.isNotEmpty) {
      path.moveTo(coordinates.first.dx, coordinates.first.dy);
      fillPath.moveTo(coordinates.first.dx, size.height); // Start bottom-left
      fillPath.lineTo(coordinates.first.dx, coordinates.first.dy);

      for (int i = 1; i < coordinates.length; i++) {
        // Curve smoothing (Simple cubic bezier or just straight lines for time series)
        // Using straight lines for accuracy in this context, or simple smoothing could be added.
        // Let's use straightforward Lineto for clear data points.
        path.lineTo(coordinates[i].dx, coordinates[i].dy);
        fillPath.lineTo(coordinates[i].dx, coordinates[i].dy);
      }
      
      fillPath.lineTo(coordinates.last.dx, size.height); // Bottom-right
      fillPath.close();
    }

    // Draw
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw Dots
    for (final c in coordinates) {
      canvas.drawCircle(c, 5, Paint()..color = surfaceColor); // Eraser/Background
      canvas.drawCircle(c, 4, dotPaintFill);
      canvas.drawCircle(c, 4, dotPaintBorder); // Ring effect
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}
