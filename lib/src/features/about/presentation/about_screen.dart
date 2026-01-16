import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/backend_config.dart';
import '../../../shared/widgets/rounded_card.dart';
import '../../admin/presentation/admin_dashboard_screen.dart';
import '../../session/application/session_controller.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              final session = ref.read(sessionControllerProvider);
              if (session.role == UserRole.admin) {
                context.go('/app/admin');
              } else {
                context.go('/app/home');
              }
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ═══════════════════════════════════════════════════════════════
          // HERO HEADER
          // ═══════════════════════════════════════════════════════════════
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withOpacity(0.15),
                  scheme.secondary.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.primary.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(Icons.local_cafe_rounded, size: 48, color: scheme.primary),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  'JAMUIN',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: scheme.primary,
                        letterSpacing: 3,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Jamu Indonesia Vending Machine',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: scheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════════
          // DESKRIPSI SISTEM
          // ═══════════════════════════════════════════════════════════════
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(icon: Icons.info_outline, title: 'Deskripsi Sistem', scheme: scheme),
                const SizedBox(height: 12),
                Text(
                  'Jamuin adalah sistem informasi vending machine pintar berbasis IoT untuk distribusi minuman jamu tradisional Indonesia.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 12),
                _FeatureBullet(text: 'Peta interaktif lokasi mesin vending', scheme: scheme),
                _FeatureBullet(text: 'Pembayaran cashless via Midtrans', scheme: scheme),
                _FeatureBullet(text: 'Rekomendasi AI dengan sistem pakar', scheme: scheme),
                _FeatureBullet(text: 'Monitoring suhu & status mesin realtime', scheme: scheme),
                _FeatureBullet(text: 'Dashboard admin untuk manajemen', scheme: scheme),
                _FeatureBullet(text: 'Integrasi MQTT untuk kontrol IoT', scheme: scheme),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════════
          // VIDEO DEMO
          // ═══════════════════════════════════════════════════════════════
          RoundedCard(
            color: Colors.red.shade50,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.play_circle_fill, color: Colors.red, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Video Demo Youtube', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          'https://youtube.com/watch?v=PLACEHOLDER',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red.shade700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new, size: 18, color: Colors.red.shade400),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════════
          // TIM PENGEMBANG
          // ═══════════════════════════════════════════════════════════════
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(icon: Icons.people_outline, title: 'Tim Pengembang', scheme: scheme),
                const SizedBox(height: 12),
                _DeveloperCard(name: 'Fathurrahman Pratama Putra', nrp: '15-2023-057', scheme: scheme),
                const SizedBox(height: 8),
                _DeveloperCard(name: 'Muhammad Fariz Alfaritzi', nrp: '15-2023-124', scheme: scheme),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════════
          // ARSITEKTUR SISTEM
          // ═══════════════════════════════════════════════════════════════
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(icon: Icons.architecture, title: 'Arsitektur Sistem', scheme: scheme),
                const SizedBox(height: 16),
                // Architecture Flow
                _ArchitectureFlow(scheme: scheme),
                const SizedBox(height: 20),
                Divider(color: scheme.outlineVariant),
                const SizedBox(height: 16),
                // Tech Stack Grid
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TechChip(label: 'Flutter', icon: Icons.phone_android, scheme: scheme),
                    _TechChip(label: 'NestJS', icon: Icons.cloud, scheme: scheme),
                    _TechChip(label: 'PostgreSQL', icon: Icons.storage, scheme: scheme),
                    _TechChip(label: 'MQTT', icon: Icons.sensors, scheme: scheme),
                    _TechChip(label: 'Socket.IO', icon: Icons.wifi, scheme: scheme),
                    _TechChip(label: 'JWT Auth', icon: Icons.security, scheme: scheme),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════════
          // PUBLIC API
          // ═══════════════════════════════════════════════════════════════
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(icon: Icons.api, title: 'Public API (External)', scheme: scheme),
                const SizedBox(height: 12),
                _PublicApiCard(
                  name: 'MapTiler',
                  icon: Icons.map,
                  color: Colors.blue,
                  desc: 'Vector maps untuk peta lokasi mesin',
                  endpoint: 'api.maptiler.com',
                ),
                const SizedBox(height: 10),
                _PublicApiCard(
                  name: 'Midtrans',
                  icon: Icons.payment,
                  color: Colors.indigo,
                  desc: 'Payment gateway (QRIS, Transfer, E-Wallet)',
                  endpoint: 'app.midtrans.com',
                ),
                const SizedBox(height: 10),
                _PublicApiCard(
                  name: 'Google Gemini AI',
                  icon: Icons.auto_awesome,
                  color: Colors.deepPurple,
                  desc: 'Generative AI untuk rekomendasi jamu',
                  endpoint: 'generativelanguage.googleapis.com',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════════
          // BACKEND API ENDPOINTS
          // ═══════════════════════════════════════════════════════════════
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(icon: Icons.code, title: 'Backend API Endpoints', scheme: scheme),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Base URL: ${BackendConfig.baseUrl}',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: scheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 16),

                // Auth
                _EndpointGroup(
                  title: 'Authentication',
                  color: Colors.teal,
                  endpoints: [
                    ('POST', '/auth/register', 'Registrasi user'),
                    ('POST', '/auth/login', 'Login → JWT token'),
                  ],
                ),
                const SizedBox(height: 12),

                // Machines
                _EndpointGroup(
                  title: 'Machines',
                  color: Colors.orange,
                  endpoints: [
                    ('GET', '/machines', 'List semua mesin'),
                    ('GET', '/machines/online', 'Mesin online'),
                    ('GET', '/machines/dashboard', 'Stats admin 🔒'),
                    ('POST', '/machines', 'Tambah mesin 🔒'),
                    ('PATCH', '/machines/:id', 'Update mesin 🔒'),
                    ('DELETE', '/machines/:id', 'Hapus mesin 🔒'),
                  ],
                ),
                const SizedBox(height: 12),

                // Products
                _EndpointGroup(
                  title: 'Products',
                  color: Colors.green,
                  endpoints: [
                    ('GET', '/products', 'List produk'),
                    ('GET', '/products/:id', 'Detail produk'),
                    ('GET', '/products/machine/:id', 'Produk per mesin'),
                    ('PUT', '/products/:id/machine/:id/stock', 'Set stok'),
                  ],
                ),
                const SizedBox(height: 12),

                // Payments
                _EndpointGroup(
                  title: 'Payments',
                  color: Colors.purple,
                  endpoints: [
                    ('POST', '/payments/create', 'Buat transaksi 🔒'),
                    ('POST', '/payments/notification', 'Webhook Midtrans'),
                    ('GET', '/payments/status/:orderId', 'Cek status'),
                    ('GET', '/payments/my-history', 'Riwayat user 🔒'),
                    ('POST', '/payments/cancel/:orderId', 'Batalkan'),
                  ],
                ),
                const SizedBox(height: 12),

                // Expert System
                _EndpointGroup(
                  title: 'Expert System',
                  color: Colors.deepOrange,
                  endpoints: [
                    ('GET', '/expert-system/start', 'Mulai diagnosa'),
                    ('POST', '/expert-system/diagnose', 'Kirim jawaban'),
                    ('GET', '/expert-system/questions', 'List pertanyaan'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════════
          // CONTOH API
          // ═══════════════════════════════════════════════════════════════
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(icon: Icons.data_object, title: 'Contoh Request & Response', scheme: scheme),
                const SizedBox(height: 12),
                _ApiExampleCard(
                  title: 'Login',
                  request: '{\n  "email": "user@mail.com",\n  "password": "***"\n}',
                  response: '{\n  "token": "eyJhbGc...",\n  "user": { "id": 1, "role": "user" }\n}',
                  scheme: scheme,
                ),
                const SizedBox(height: 12),
                _ApiExampleCard(
                  title: 'Create Payment',
                  request: '{\n  "productId": 1,\n  "machineId": 2\n}',
                  response: '{\n  "orderId": "ORDER-123",\n  "snapToken": "abc123",\n  "redirectUrl": "https://..."\n}',
                  scheme: scheme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════════
          // MQTT FLOW
          // ═══════════════════════════════════════════════════════════════
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(icon: Icons.sensors, title: 'MQTT & IoT Data Flow', scheme: scheme),
                const SizedBox(height: 12),
                Text('Topic Pattern:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _MqttTopicRow(topic: '{topic}/temperature', desc: 'Data suhu & humidity'),
                _MqttTopicRow(topic: '{topic}/status', desc: 'Online/Offline/Maintenance'),
                _MqttTopicRow(topic: '{topic}/dispense/{id}', desc: 'Command ON/OFF'),
                const SizedBox(height: 16),
                Text('Flow Dispense:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _FlowStepItem(step: '1', text: 'User bayar → status "settlement"', scheme: scheme),
                _FlowStepItem(step: '2', text: 'Backend publish MQTT → "ON"', scheme: scheme),
                _FlowStepItem(step: '3', text: 'Mesin keluarkan produk', scheme: scheme),
                _FlowStepItem(step: '4', text: 'Backend publish → "OFF" (5 detik)', scheme: scheme),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════════
          // DATABASE
          // ═══════════════════════════════════════════════════════════════
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(icon: Icons.storage, title: 'Database Schema', scheme: scheme),
                const SizedBox(height: 12),
                Text('PostgreSQL Tables:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _DbTableChip('users'),
                    _DbTableChip('machines'),
                    _DbTableChip('products'),
                    _DbTableChip('machine_products'),
                    _DbTableChip('transactions'),
                    _DbTableChip('temperature_logs'),
                    _DbTableChip('symptom_questions'),
                    _DbTableChip('rules'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════════
          // MOBILE APP STRUCTURE
          // ═══════════════════════════════════════════════════════════════
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(icon: Icons.phone_android, title: 'Struktur Mobile App', scheme: scheme),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _FeatureChip('auth', Icons.login, scheme),
                    _FeatureChip('home', Icons.home, scheme),
                    _FeatureChip('map', Icons.map, scheme),
                    _FeatureChip('products', Icons.inventory_2, scheme),
                    _FeatureChip('cart', Icons.shopping_cart, scheme),
                    _FeatureChip('checkout', Icons.payment, scheme),
                    _FeatureChip('transactions', Icons.receipt_long, scheme),
                    _FeatureChip('expert_system', Icons.psychology, scheme),
                    _FeatureChip('admin', Icons.admin_panel_settings, scheme),
                    _FeatureChip('inventory', Icons.inventory, scheme),
                    _FeatureChip('about', Icons.info, scheme),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Footer
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [scheme.primary.withOpacity(0.1), scheme.secondary.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'UAS Pemrograman Mobile',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: scheme.primary),
                      ),
                      Text(
                        'Ganjil 2025/2026',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      Text(
                        'Institut Teknologi Nasional Bandung',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.secondary),
                      ),
                    ],
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

// ═══════════════════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.icon, required this.title, required this.scheme});
  final IconData icon;
  final String title;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: scheme.primary),
        ),
        const SizedBox(width: 12),
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({required this.text, required this.scheme});
  final String text;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: scheme.secondary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard({required this.name, required this.nrp, required this.scheme});
  final String name, nrp;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: scheme.primary.withOpacity(0.15),
            child: Text(name[0], style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(nrp, style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchitectureFlow extends StatelessWidget {
  const _ArchitectureFlow({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ArchBox(label: 'Mobile\nApp', icon: Icons.phone_android, color: scheme.primary, scheme: scheme),
        _ArchArrow(scheme: scheme),
        _ArchBox(label: 'REST\nAPI', icon: Icons.http, color: Colors.blue, scheme: scheme),
        _ArchArrow(scheme: scheme),
        _ArchBox(label: 'Backend\nNestJS', icon: Icons.cloud, color: Colors.indigo, scheme: scheme),
        _ArchArrow(scheme: scheme),
        _ArchBox(label: 'Postgres\nDB', icon: Icons.storage, color: Colors.teal, scheme: scheme),
      ],
    );
  }
}

class _ArchBox extends StatelessWidget {
  const _ArchBox({required this.label, required this.icon, required this.color, required this.scheme});
  final String label;
  final IconData icon;
  final Color color;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _ArchArrow extends StatelessWidget {
  const _ArchArrow({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.arrow_forward, size: 14, color: scheme.outline),
    );
  }
}

class _TechChip extends StatelessWidget {
  const _TechChip({required this.label, required this.icon, required this.scheme});
  final String label;
  final IconData icon;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.secondary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.secondary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: scheme.secondary)),
        ],
      ),
    );
  }
}

class _PublicApiCard extends StatelessWidget {
  const _PublicApiCard({required this.name, required this.icon, required this.color, required this.desc, required this.endpoint});
  final String name, desc, endpoint;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
                Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                Text(endpoint, style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: color.withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EndpointGroup extends StatelessWidget {
  const _EndpointGroup({required this.title, required this.color, required this.endpoints});
  final String title;
  final Color color;
  final List<(String, String, String)> endpoints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(height: 6),
        ...endpoints.map((e) => _EndpointRow(method: e.$1, path: e.$2, desc: e.$3)),
      ],
    );
  }
}

class _EndpointRow extends StatelessWidget {
  const _EndpointRow({required this.method, required this.path, required this.desc});
  final String method, path, desc;

  @override
  Widget build(BuildContext context) {
    Color c = Colors.grey;
    if (method == 'GET') c = Colors.blue;
    if (method == 'POST') c = Colors.green;
    if (method == 'PATCH' || method == 'PUT') c = Colors.orange;
    if (method == 'DELETE') c = Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3, left: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(method, textAlign: TextAlign.center, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: c)),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(path, style: const TextStyle(fontSize: 10, fontFamily: 'monospace'))),
          Text(desc, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _ApiExampleCard extends StatelessWidget {
  const _ApiExampleCard({required this.title, required this.request, required this.response, required this.scheme});
  final String title, request, response;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: scheme.primary)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Request', style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(6)),
                      child: Text(request, style: const TextStyle(fontSize: 9, fontFamily: 'monospace', color: Colors.greenAccent)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Response', style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(6)),
                      child: Text(response, style: const TextStyle(fontSize: 9, fontFamily: 'monospace', color: Colors.lightBlueAccent)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MqttTopicRow extends StatelessWidget {
  const _MqttTopicRow({required this.topic, required this.desc});
  final String topic, desc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(topic, style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.deepPurple))),
          Text(desc, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _FlowStepItem extends StatelessWidget {
  const _FlowStepItem({required this.step, required this.text, required this.scheme});
  final String step, text;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          CircleAvatar(radius: 10, backgroundColor: scheme.secondary, child: Text(step, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}

class _DbTableChip extends StatelessWidget {
  const _DbTableChip(this.name);
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.indigo.withOpacity(0.3)),
      ),
      child: Text(name, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.w600, color: Colors.indigo)),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip(this.name, this.icon, this.scheme);
  final String name;
  final IconData icon;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: scheme.primary),
          const SizedBox(width: 4),
          Text(name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: scheme.primary)),
        ],
      ),
    );
  }
}
