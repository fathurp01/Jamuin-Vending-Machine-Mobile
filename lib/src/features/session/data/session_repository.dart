import '../../../core/persistence/local_storage.dart';
import '../application/session_controller.dart';

abstract class SessionRepository {
  Future<SessionState?> read();
  Future<void> write(SessionState state);
  Future<void> clear();
}

final class LocalSessionRepository implements SessionRepository {
  LocalSessionRepository(this._storage);

  static const _key = 'session.v1';
  final LocalStorage _storage;

  @override
  Future<SessionState?> read() async {
    final m = _storage.getJsonMap(_key);
    if (m == null) return null;

    final roleRaw = (m['role'] as String?) ?? 'customer';
    final role = roleRaw == 'admin' ? UserRole.admin : UserRole.customer;

    final isAuth = (m['isAuthenticated'] as bool?) ?? false;
    if (!isAuth) return null;

    return SessionState(
      isAuthenticated: true,
      displayName: m['displayName'] as String?,
      email: m['email'] as String?,
      role: role,
      points: (m['points'] as int?) ?? 120,
      selectedMachineName: m['selectedMachineName'] as String?,
    );
  }

  @override
  Future<void> write(SessionState state) async {
    await _storage.setJson(_key, {
      'isAuthenticated': state.isAuthenticated,
      'displayName': state.displayName,
      'email': state.email,
      'role': state.role == UserRole.admin ? 'admin' : 'customer',
      'points': state.points,
      'selectedMachineName': state.selectedMachineName,
    });
  }

  @override
  Future<void> clear() async {
    await _storage.remove(_key);
  }
}
