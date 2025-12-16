import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../session/application/session_controller.dart';
import '../../session/application/session_persistence_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  UserRole _role = UserRole.customer;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    // UI-only authentication: accept any credentials that pass validation.
    ref
        .read(sessionControllerProvider.notifier)
        .applyLogin(displayName: name, email: email, role: _role);

    final repo = ref.read(sessionRepositoryProvider);
    await repo.write(ref.read(sessionControllerProvider));

    if (!mounted) return;
    setState(() => _submitting = false);

    messenger.showSnackBar(const SnackBar(content: Text('Logged in')));
    router.go(_role == UserRole.admin ? '/app/admin' : '/app/home');
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
            'Sign in to continue (UI-only demo).',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          SegmentedButton<UserRole>(
            segments: const [
              ButtonSegment(value: UserRole.customer, label: Text('Customer')),
              ButtonSegment(value: UserRole.admin, label: Text('Admin')),
            ],
            selected: {_role},
            onSelectionChanged: (s) => setState(() => _role = s.first),
          ),
          const SizedBox(height: 14),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Name is required';
                    if (t.length < 2) return 'Name is too short';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
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
