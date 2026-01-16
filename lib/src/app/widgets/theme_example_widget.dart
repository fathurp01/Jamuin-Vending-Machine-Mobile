import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Example widget demonstrating the new theme
/// This shows how to use the updated theme in your components
class ThemeExampleWidget extends StatelessWidget {
  const ThemeExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Example'),
      ),
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          // Section: Colors
          Text(
            'Colors',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary600,
                    borderRadius: AppBorderRadius.radiusMd,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Primary',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.secondary600,
                    borderRadius: AppBorderRadius.radiusMd,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Secondary',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section: Gradients
          Text(
            'Gradients',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppBorderRadius.radiusMd,
            ),
            alignment: Alignment.center,
            child: const Text(
              'Primary Gradient',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section: Cards
          Text(
            'Cards',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Title',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is a card with the new theme styling. It has elevated shadow and rounded corners.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section: Buttons
          Text(
            'Buttons',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {},
            child: const Text('Primary Button'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Secondary Button'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Outline Button'),
          ),
          const SizedBox(height: 24),

          // Section: Typography
          Text(
            'Typography',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Display Large (Poppins)',
            style: AppTextStyles.displayMedium.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            'Headline Large (Poppins)',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Body text with Inter font. This is a paragraph demonstrating the new typography system. It has proper line height and spacing.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Section: Semantic Colors
          Text(
            'Semantic Colors',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _SemanticColorChip(
            label: 'Success',
            color: AppColors.success,
          ),
          const SizedBox(height: 8),
          _SemanticColorChip(
            label: 'Warning',
            color: AppColors.warning,
          ),
          const SizedBox(height: 8),
          _SemanticColorChip(
            label: 'Error',
            color: AppColors.error,
          ),
          const SizedBox(height: 8),
          _SemanticColorChip(
            label: 'Info',
            color: AppColors.info,
          ),
          const SizedBox(height: 24),

          // Section: Input Fields
          Text(
            'Input Fields',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: AppDecorations.inputField(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: AppDecorations.inputField(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: const Icon(Icons.visibility),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _SemanticColorChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SemanticColorChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppBorderRadius.radiusMd,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.circle,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
