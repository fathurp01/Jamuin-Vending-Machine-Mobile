import '../../../core/persistence/local_storage.dart';
import '../domain/inventory_state.dart';

abstract class InventoryRepository {
  Future<InventoryState?> read();
  Future<void> write(InventoryState state);
  Future<void> clear();
}

final class LocalInventoryRepository implements InventoryRepository {
  LocalInventoryRepository(this._storage);

  static const _key = 'inventory.v1';
  final LocalStorage _storage;

  @override
  Future<InventoryState?> read() async {
    final json = _storage.getJsonMap(_key);
    if (json == null) return null;
    return InventoryState.fromJson(json);
  }

  @override
  Future<void> write(InventoryState state) async {
    await _storage.setJson(_key, state.toJson());
  }

  @override
  Future<void> clear() async {
    await _storage.remove(_key);
  }
}
