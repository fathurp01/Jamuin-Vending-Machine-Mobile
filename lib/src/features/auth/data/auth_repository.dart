import 'package:dio/dio.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;

  factory AuthUser.fromJson(Map<String, Object?> json) {
    return AuthUser(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'user',
    );
  }
}

class AuthResult {
  const AuthResult({required this.user, required this.token});

  final AuthUser user;
  final String token;
}

abstract class AuthRepository {
  Future<AuthResult> login({required String email, required String password});

  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
}

final class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._dio);

  final Dio _dio;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, Object?>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = res.data ?? const <String, Object?>{};
    final user = AuthUser.fromJson(
      (data['user'] as Map).cast<String, Object?>(),
    );
    final token = (data['token'] as String?) ?? '';
    if (token.trim().isEmpty) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: 'Missing token in response',
        type: DioExceptionType.badResponse,
      );
    }
    return AuthResult(user: user, token: token);
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, Object?>>(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
    final data = res.data ?? const <String, Object?>{};
    final user = AuthUser.fromJson(
      (data['user'] as Map).cast<String, Object?>(),
    );
    final token = (data['token'] as String?) ?? '';
    if (token.trim().isEmpty) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: 'Missing token in response',
        type: DioExceptionType.badResponse,
      );
    }
    return AuthResult(user: user, token: token);
  }
}

AuthRepository createAuthRepository(Dio dio) => ApiAuthRepository(dio);
