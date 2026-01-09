import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../map/presentation/machine_providers.dart';
import '../../session/application/session_controller.dart';
import '../../../shared/widgets/rounded_card.dart';

class AdminAddMachineScreen extends ConsumerStatefulWidget {
  const AdminAddMachineScreen({super.key});

  @override
  ConsumerState<AdminAddMachineScreen> createState() =>
      _AdminAddMachineScreenState();
}

class _AdminAddMachineScreenState extends ConsumerState<AdminAddMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _mqttTopicCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  bool _saving = false;
  String _status = 'offline';

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _mqttTopicCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  double? _parseDoubleOrNull(String input) {
    final v = input.trim();
    if (v.isEmpty) return null;
    return double.tryParse(v);
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(machinesRepositoryProvider);
      final lat = _parseDoubleOrNull(_latCtrl.text);
      final lng = _parseDoubleOrNull(_lngCtrl.text);

      await repo.createMachine({
        'code': _codeCtrl.text.trim(),
        'name': _nameCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'mqttTopic': _mqttTopicCtrl.text.trim(),
        if (lat != null) 'latitude': lat,
        if (lng != null) 'longitude': lng,
        'status': _status,
      });

      if (!mounted) return;
      ref.invalidate(machinesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesin berhasil ditambahkan.')),
      );
      context.go('/app/admin');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambahkan mesin: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    if (session.role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tambah Mesin')),
        body: Center(
          child: RoundedCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, color: scheme.onSurfaceVariant),
                const SizedBox(height: 10),
                Text(
                  'Access denied',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'This area is available for admins only.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Mesin')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            RoundedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data mesin',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _codeCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Code',
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                    ),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Code wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      prefixIcon: Icon(Icons.storefront_outlined),
                    ),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Lokasi wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _mqttTopicCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'MQTT Topic',
                      prefixIcon: Icon(Icons.wifi_tethering_outlined),
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? 'MQTT topic wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.toggle_on_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'offline',
                        child: Text('offline'),
                      ),
                      DropdownMenuItem(value: 'online', child: Text('online')),
                      DropdownMenuItem(
                        value: 'maintenance',
                        child: Text('maintenance'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _status = v);
                    },
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
                    'Koordinat (opsional)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _latCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      prefixIcon: Icon(Icons.my_location_outlined),
                    ),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return null;
                      return double.tryParse(value) == null
                          ? 'Latitude tidak valid'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lngCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      prefixIcon: Icon(Icons.my_location_outlined),
                    ),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return null;
                      return double.tryParse(value) == null
                          ? 'Longitude tidak valid'
                          : null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SafeArea(
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_circle_outline),
                label: Text(_saving ? 'Menyimpan...' : 'Tambah Mesin'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
