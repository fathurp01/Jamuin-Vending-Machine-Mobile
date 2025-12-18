import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/auth_providers.dart';
import '../../session/application/session_controller.dart';
import '../../session/application/session_persistence_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.redirectTo});

  /// Optional in-app redirect after successful customer login.
  /// Example: '/app/cart'
  final String? redirectTo;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    try {
      final auth = ref.read(authRepositoryProvider);
      final result = await auth.login(email: email, password: password);

      if (!mounted) return;
      ref
          .read(sessionControllerProvider.notifier)
          .applyLogin(
            userId: result.user.id,
            displayName: result.user.name,
            email: result.user.email,
            phone: result.user.phone,
            token: result.token,
            role: result.user.role == 'admin'
                ? UserRole.admin
                : UserRole.customer,
          );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(SnackBar(content: Text('Login gagal: $e')));
      return;
    }

    final sessionRepo = ref.read(sessionRepositoryProvider);
    await sessionRepo.write(ref.read(sessionControllerProvider));

    if (!mounted) return;
    setState(() => _submitting = false);

    messenger.showSnackBar(const SnackBar(content: Text('Berhasil masuk')));

    // Navigate based on user role.
    // - Admin always goes to admin dashboard
    // - Customer optionally returns to provided redirect (e.g., cart)
    final currentSession = ref.read(sessionControllerProvider);
    final destination = currentSession.role == UserRole.admin
        ? '/app/admin'
        : (widget.redirectTo?.trim().isNotEmpty == true
              ? widget.redirectTo!
              : '/app/home');
    router.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Masuk')),
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
            'Masuk untuk melanjutkan (demo).',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Email wajib diisi';
                    if (!t.contains('@') || !t.contains('.')) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Password wajib diisi';
                    if (t.length < 6) return 'Minimal 6 karakter';
                    return null;
                  },
                  onFieldSubmitted: (_) => _submitting ? null : _submit(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Masuk'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push('/auth/register'),
            child: const Text('Buat akun'),
          ),
          TextButton(
            onPressed: () => context.go('/app/home'),
            child: const Text('Kembali ke Dashboard'),
          ),
        ],
      ),
    );
  }
}
