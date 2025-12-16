import '../../../core/persistence/local_storage.dart';
import '../../session/application/session_controller.dart';
import '../domain/user_account.dart';

abstract class UserRepository {
  Future<void> ensureSeededUsers();
  Future<UserAccount?> findByEmail(String email);
  Future<void> upsert(UserAccount account);
}

final class LocalUserRepository implements UserRepository {
  LocalUserRepository(this._storage);

  static const _key = 'users.v1';
  final LocalStorage _storage;

  // Demo-only. Keep this out of the UI; admin must know the credentials.
  static const _seedAdmin = UserAccount(
    email: 'admin@jamuin.local',
    displayName: 'Admin',
    password: 'admin123',
    role: UserRole.admin,
  );

  @override
  Future<void> ensureSeededUsers() async {
    final items = await _listInternal();
    final hasAdmin = items.any(
      (u) => u.role == UserRole.admin && u.email == _seedAdmin.email,
    );
    if (hasAdmin) return;

    await upsert(_seedAdmin);
  }

  @override
  Future<UserAccount?> findByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    final items = await _listInternal();
    for (final u in items) {
      if (u.email.trim().toLowerCase() == normalized) return u;
    }
    return null;
  }

  @override
  Future<void> upsert(UserAccount account) async {
    final normalized = account.email.trim().toLowerCase();
    if (normalized.isEmpty) return;

    final items = await _listInternal();
    final next = <UserAccount>[];
    bool replaced = false;

    for (final u in items) {
      if (u.email.trim().toLowerCase() == normalized) {
        next.add(account);
        replaced = true;
      } else {
        next.add(u);
      }
    }

    if (!replaced) next.add(account);

    await _storage.setJson(
      _key,
      next.map((e) => e.toJson()).toList(growable: false),
    );
  }

  Future<List<UserAccount>> _listInternal() async {
    final raw = _storage.getJsonList(_key);
    if (raw == null) return const [];

    final items = <UserAccount>[];
    for (final v in raw) {
      if (v is Map) {
        items.add(UserAccount.fromJson(v.cast<String, Object?>()));
      }
    }
    return items;
  }
}
