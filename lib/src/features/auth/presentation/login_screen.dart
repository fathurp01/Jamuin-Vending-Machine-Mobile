import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/user_providers.dart';
import '../../session/application/session_controller.dart';
import '../../session/application/session_persistence_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

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

    final users = ref.read(userRepositoryProvider);
    await users.ensureSeededUsers();

    final account = await users.findByEmail(email);
    if (!mounted) return;

    if (account == null) {
      setState(() => _submitting = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Account not found. Please register.')),
      );
      return;
    }

    // Demo-only password check.
    if (account.password != password) {
      setState(() => _submitting = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Invalid email or password.')),
      );
      return;
    }

    ref
        .read(sessionControllerProvider.notifier)
        .applyLogin(
          displayName: account.displayName,
          email: account.email,
          role: account.role,
        );

    final sessionRepo = ref.read(sessionRepositoryProvider);
    await sessionRepo.write(ref.read(sessionControllerProvider));

    if (!mounted) return;
    setState(() => _submitting = false);

    messenger.showSnackBar(const SnackBar(content: Text('Logged in')));
    router.go(account.role == UserRole.admin ? '/app/admin' : '/app/home');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
            'Sign in to continue (demo).',
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
                    if (t.isEmpty) return 'Email is required';
                    if (!t.contains('@') || !t.contains('.')) {
                      return 'Enter a valid email';
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
                    if (t.isEmpty) return 'Password is required';
                    if (t.length < 6) return 'Min 6 characters';
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
                : const Text('Login'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push('/auth/register'),
            child: const Text('Create an account'),
          ),
        ],
      ),
    );
  }
}
