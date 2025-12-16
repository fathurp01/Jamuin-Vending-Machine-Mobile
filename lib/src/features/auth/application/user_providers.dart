import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/application/session_persistence_providers.dart';
import '../data/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final storage = ref.watch(localStorageProvider).requireValue;
  return LocalUserRepository(storage);
});
