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
      onError: (error, handler) {
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
