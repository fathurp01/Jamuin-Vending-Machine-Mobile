import 'package:flutter/material.dart';

import '../../../core/config/backend_config.dart';
import '../../../core/config/public_apis.dart';
import '../../../shared/widgets/rounded_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            'Jamuin',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Mobile vending machine ordering app (UTS).\nUses Jamuin backend API (NestJS).',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backend API (Jamuin)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Base URL:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                SelectableText(BackendConfig.baseUrl),
                const SizedBox(height: 10),
                Text(
                  'Auth header:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SelectableText('Authorization: Bearer <token>'),
                const SizedBox(height: 10),
                Text(
                  'Main endpoints:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SelectableText(
                  'POST /auth/register\n'
                  'POST /auth/login\n'
                  'GET  /machines/online\n'
                  'GET  /products\n'
                  'GET  /products/:id\n'
                  'POST /payments/create   (auth, machine must be ONLINE)\n'
                  'GET  /payments/my-history (auth)\n'
                  'GET  /payments/status/:orderId\n'
                  'POST /payments/cancel/:orderId\n'
                  'POST /expert-system/diagnose',
                ),
                const SizedBox(height: 10),
                Text(
                  'Run with custom base URL (example):',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SelectableText(
                  'flutter run --dart-define=BACKEND_BASE_URL=http://YOUR_PC_IP:3000',
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
                  'Public API',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Name: ${PublicApis.maptilerName}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Universal format:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                SelectableText(PublicApis.maptilerUniversalFormat),
                const SizedBox(height: 10),
                Text(
                  'Vector style JSON:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                SelectableText(PublicApis.maptilerStreetsV4StyleUrl),
              ],
            ),
          ),
          const SizedBox(height: 12),
          RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Developer identity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  '1) Name: Fathurrahman Pratama Putra',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '   NRP: 15-2023-057',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '   Class: AA',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '   Course: Pemrograman Mobile',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '   Year: 2025-2026',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Divider(height: 1, color: scheme.outlineVariant),
                const SizedBox(height: 10),
                Text(
                  '2) Name: Muhammad Fariz Alfaritzi',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '   NRP: 15-2023-124',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '   Class: AA',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '   Course: Pemrograman Mobile',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '   Year: 2025-2026',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
