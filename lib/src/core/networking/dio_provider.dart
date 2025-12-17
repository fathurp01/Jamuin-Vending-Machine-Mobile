import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/session/application/session_controller.dart';
import '../config/backend_config.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: BackendConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(sessionControllerProvider).token;
        if (token != null && token.trim().isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ${token.trim()}';
        }
        handler.next(options);
      },
    ),
  );

  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: false));

  return dio;
});
