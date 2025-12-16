import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/local_storage.dart';
import '../data/session_repository.dart';

final localStorageProvider = FutureProvider<LocalStorage>((ref) async {
  return LocalStorage.create();
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final storage = ref.watch(localStorageProvider).requireValue;
  return LocalSessionRepository(storage);
});
