import 'package:dio/dio.dart';

import '../domain/expert_models.dart';

abstract class ExpertSystemRepository {
  Future<ExpertInitResult> initialize();
  Future<ExpertStartResult> start();
  Future<ExpertDiagnoseResult> diagnose({
    required String sessionId,
    required String questionId,
    required String selectedOptionId,
  });
}

final class ApiExpertSystemRepository implements ExpertSystemRepository {
  ApiExpertSystemRepository(this._dio);

  final Dio _dio;

  @override
  Future<ExpertInitResult> initialize() async {
    final res = await _dio.post<Map<String, Object?>>(
      '/expert-system/initialize',
    );
    return ExpertInitResult.fromJson(res.data ?? const <String, Object?>{});
  }

  @override
  Future<ExpertStartResult> start() async {
    final res = await _dio.get<Map<String, Object?>>('/expert-system/start');
    return ExpertStartResult.fromJson(res.data ?? const <String, Object?>{});
  }

  @override
  Future<ExpertDiagnoseResult> diagnose({
    required String sessionId,
    required String questionId,
    required String selectedOptionId,
  }) async {
    final res = await _dio.post<Map<String, Object?>>(
      '/expert-system/diagnose',
      data: {
        'sessionId': sessionId,
        'questionId': questionId,
        'selectedOptionId': selectedOptionId,
      },
    );
    return ExpertDiagnoseResult.fromJson(res.data ?? const <String, Object?>{});
  }
}
