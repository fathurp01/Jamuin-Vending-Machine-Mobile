import 'package:flutter/material.dart';

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
            'Mobile vending machine ordering app (UTS).\nFrontend-only (no backend).',
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
                  'Name: (fill)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'NIM: (fill)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Class: (fill)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Course/Lecturer: (fill)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Year/Semester: 2025',
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
