import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/rounded_card.dart';
import '../application/expert_system_controller.dart';

class ExpertSystemScreen extends ConsumerWidget {
  const ExpertSystemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expertSystemControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Konsultasi AI')),
      body: switch (state) {
        ExpertInitial() => _Initial(
          onStart: () =>
              ref.read(expertSystemControllerProvider.notifier).start(),
        ),
        ExpertLoading() => const Center(child: CircularProgressIndicator()),
        ExpertQuestionState(
          :final sessionId,
          :final question,
          :final answered,
        ) =>
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              RoundedCard(
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: scheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Pertanyaan ${answered.length + 1}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                question.text,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              ...question.options.map(
                (opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => ref
                        .read(expertSystemControllerProvider.notifier)
                        .submit(
                          sessionId: sessionId,
                          question: question,
                          option: opt,
                        ),
                    child: RoundedCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              opt.text,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: scheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ExpertRecommendationState(:final recommendation, :final answered) =>
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              RoundedCard(
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rekomendasi',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recommendation.productName,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
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
                      'Alasan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recommendation.alasan,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (answered.isNotEmpty)
                RoundedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jawaban Anda',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      ...answered.map(
                        (it) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                it.questionText,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                it.answerText,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: recommendation.productId > 0
                    ? () => context.push(
                        '/app/products/${recommendation.productId}',
                      )
                    : null,
                child: const Text('Lihat Produk'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () =>
                    ref.read(expertSystemControllerProvider.notifier).reset(),
                child: const Text('Mulai Ulang'),
              ),
            ],
          ),
        ExpertError(:final message) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: scheme.error,
                  size: 44,
                ),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.read(expertSystemControllerProvider.notifier).start(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      },
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        Icon(Icons.favorite, size: 96, color: scheme.primary),
        const SizedBox(height: 18),
        Text(
          'Konsultasi AI Jamu',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          'Sistem AI akan menanyakan beberapa pertanyaan tentang kondisi kesehatan Anda untuk memberikan rekomendasi jamu yang tepat.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        RoundedCard(
          child: Column(
            children: const [
              _Bullet(text: 'Rekomendasi personal'),
              _Bullet(text: 'Berdasarkan sistem pakar'),
              _Bullet(text: 'Cepat dan mudah'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(onPressed: onStart, child: const Text('Mulai Konsultasi')),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
