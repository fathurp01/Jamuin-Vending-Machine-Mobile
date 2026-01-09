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

    // Admin must not be persisted between full app launches.
    if (role == UserRole.admin) {
      await clear();
      return null;
    }

    final isAuth = (m['isAuthenticated'] as bool?) ?? false;
    if (!isAuth) return null;

    final token = (m['token'] as String?)?.trim();
    if (token == null || token.isEmpty) return null;

    return SessionState(
      isAuthenticated: true,
      displayName: m['displayName'] as String?,
      email: m['email'] as String?,
      phone: m['phone'] as String?,
      userId: m['userId'] as int?,
      token: token,
      role: role,
      points: (m['points'] as int?) ?? 120,
      selectedMachineId: null,
      selectedMachineName: null,
    );
  }

  @override
  Future<void> write(SessionState state) async {
    // Persist only for customer. Admin should be in-memory only so that when
    // the app is truly closed (killed), admin is auto-logged out.
    if (state.role == UserRole.admin) {
      await clear();
      return;
    }
    await _storage.setJson(_key, {
      'isAuthenticated': state.isAuthenticated,
      'displayName': state.displayName,
      'email': state.email,
      'phone': state.phone,
      'userId': state.userId,
      'token': state.token,
      'role': state.role == UserRole.admin ? 'admin' : 'customer',
      'points': state.points,
      // Do not persist machine selection across app restarts.
      'selectedMachineId': null,
      'selectedMachineName': null,
    });
  }

  @override
  Future<void> clear() async {
    await _storage.remove(_key);
  }
}
