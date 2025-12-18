import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../session/application/session_controller.dart';
import '../../session/application/session_persistence_providers.dart';
import '../../../shared/widgets/rounded_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final session = ref.watch(sessionControllerProvider);

    if (!session.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 48,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(height: 10),
                Text(
                  'Login untuk Melihat Profil',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Silakan login untuk melihat profil dan informasi akun.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => context.push('/auth/login'),
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          RoundedCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                  child: Icon(Icons.person, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.displayName ?? 'Pengguna',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.phone ?? '-',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        session.email ?? '-',
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
          const SizedBox(height: 12),
          if (session.role == UserRole.admin)
            _MenuTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Admin',
              onTap: () => context.push('/app/admin'),
            ),
          _MenuTile(
            icon: Icons.edit,
            title: 'Edit Profil',
            onTap: () => _showNotImplemented(context),
          ),
          _MenuTile(
            icon: Icons.history,
            title: 'Riwayat Pembelian',
            onTap: () => context.push('/app/history'),
          ),
          _MenuTile(
            icon: Icons.settings,
            title: 'Pengaturan',
            onTap: () => _showNotImplemented(context),
          ),
          _MenuTile(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            onTap: () => context.push('/app/about'),
          ),
          const SizedBox(height: 12),
          RoundedCard(
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(Icons.logout, color: scheme.error),
                label: Text('Logout', style: TextStyle(color: scheme.error)),
                onPressed: () async {
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
                    if (context.mounted) {
                      context.go('/auth/login');
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Belum tersedia.')));
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: RoundedCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
