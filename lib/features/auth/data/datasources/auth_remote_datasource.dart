import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../dto/auth_dto.dart';

// ── Contract ───────────────────────────────────────────────────────────────────

abstract interface class IAuthRemoteDataSource {
  Future<AuthResponseDto> login(LoginRequestDto request);
  Future<AuthResponseDto> register(RegisterRequestDto request);
  Future<UserDto> getProfile();
  Future<void> logout();
}

// ── Implementation ─────────────────────────────────────────────────────────────

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSource(this._dio);

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: request.toJson(),
    );
    return AuthResponseDto.fromJson(response.data!);
  }

  @override
  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: request.toJson(),
    );
    return AuthResponseDto.fromJson(response.data!);
  }

  @override
  Future<UserDto> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.profile,
    );
    return UserDto.fromJson(response.data!);
  }

  @override
  Future<void> logout() async {
    // Optionally call a server-side logout endpoint if the backend supports it.
    // For JWT-only flows this is a no-op on the network side.
    try {
      await _dio.post<void>(ApiConstants.logout);
    } on DioException {
      // Ignore network errors on logout — local cleanup still proceeds.
    }
  }
}
