import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/dio_provider.dart';
import '../data/expert_system_repository.dart';

final expertSystemRepositoryProvider = Provider<ExpertSystemRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiExpertSystemRepository(dio);
});
