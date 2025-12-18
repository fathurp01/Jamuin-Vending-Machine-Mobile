import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../session/application/session_controller.dart';
import '../../session/application/session_persistence_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    // Give the splash animation time to play.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    // Ensure local storage is initialized.
    await ref.read(localStorageProvider.future);

    final repo = ref.read(sessionRepositoryProvider);
    final restored = await repo.read();
    if (!mounted) return;

    if (restored == null) {
      context.go('/app/home');
      return;
    }

    if (restored.userId == null || (restored.token ?? '').trim().isEmpty) {
      await repo.clear();
      if (!mounted) return;
      context.go('/app/home');
      return;
    }

    ref
        .read(sessionControllerProvider.notifier)
        .applyLogin(
          userId: restored.userId!,
          displayName: restored.displayName ?? 'User',
          email: restored.email ?? 'user@example.com',
          phone: restored.phone ?? '',
          token: restored.token!,
          role: restored.role,
        );
    if (restored.selectedMachineId != null &&
        restored.selectedMachineName != null) {
      ref
          .read(sessionControllerProvider.notifier)
          .selectMachine(
            id: restored.selectedMachineId!,
            name: restored.selectedMachineName!,
          );
    }

    context.go(restored.role == UserRole.admin ? '/app/admin' : '/app/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.local_cafe_outlined,
                    color: scheme.onPrimary,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Jamuin',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap. Pick. Enjoy.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
