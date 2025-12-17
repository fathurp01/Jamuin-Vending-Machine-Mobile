import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/dio_provider.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return createAuthRepository(dio);
});
