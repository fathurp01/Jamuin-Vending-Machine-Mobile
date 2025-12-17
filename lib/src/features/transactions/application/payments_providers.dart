import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/backend_config.dart';
import '../../../core/networking/dio_provider.dart';
import '../data/payments_repository.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiPaymentsRepository(dio, platform: BackendConfig.platform);
});

final paymentStatusProvider =
    FutureProvider.family<PaymentStatusDetail, String>((ref, orderId) async {
      final repo = ref.watch(paymentsRepositoryProvider);
      return repo.status(orderId);
    });

final paymentHistoryProvider = FutureProvider<List<PaymentHistoryItem>>((
  ref,
) async {
  final repo = ref.watch(paymentsRepositoryProvider);
  return repo.myHistory();
});
