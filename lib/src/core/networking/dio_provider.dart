import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/session/application/session_controller.dart';
import '../config/backend_config.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: BackendConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(sessionControllerProvider).token;
        if (token != null) {
          String raw = token.trim();
          if (raw.toLowerCase().startsWith('bearer ')) {
            raw = raw.substring(7).trim();
          }

          // Some storage/transport layers may accidentally wrap tokens in quotes.
          if (raw.length >= 2 && raw.startsWith('"') && raw.endsWith('"')) {
            raw = raw.substring(1, raw.length - 1).trim();
          }

          // JWT should never contain whitespace; remove defensively.
          final normalized = raw.replaceAll(RegExp(r'\s+'), '');
          if (normalized.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $normalized';

            // Safe debug logging (masked) for diagnosing 401 Invalid token.
            if (options.path.contains('/payments/my-history')) {
              final parts = normalized.split('.');
              final masked = normalized.length <= 16
                  ? normalized
                  : '${normalized.substring(0, 8)}…${normalized.substring(normalized.length - 4)}';
              print(
                '🔐 Auth header attached (masked): $masked (jwtParts=${parts.length})',
              );
            }
          }
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // If backend explicitly rejects token, clear session so user can re-login.
        final status = error.response?.statusCode;
        final data = error.response?.data;
        if (status == 401 && data is Map) {
          final message = (data['message'] as String?)?.toLowerCase().trim();
          if (message != null && message.contains('invalid token')) {
            ref.read(sessionControllerProvider.notifier).logout();
          }
        }

        // Log detailed error for debugging
        print('❌ DioError: ${error.type}');
        print('   URL: ${error.requestOptions.uri}');
        print('   Method: ${error.requestOptions.method}');
        print('   Status: ${error.response?.statusCode}');
        print('   Message: ${error.message}');
        print('   Response: ${error.response?.data}');
        handler.next(error);
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('🌐 Dio: $obj'),
    ),
  );

  return dio;
});
