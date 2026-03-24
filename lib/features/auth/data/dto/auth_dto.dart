import '../../domain/entities/user.dart';

// ── Request DTOs ──────────────────────────────────────────────────────────────

class LoginRequestDto {
  final String email;
  final String password;

  const LoginRequestDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequestDto {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() => {
        'email':     email,
        'password':  password,
        'firstName': firstName,
        'lastName':  lastName,
      };
}

// ── Response DTOs ─────────────────────────────────────────────────────────────

/// DTO de réponse du backend NestJS pour login et register.
///
/// Structure NestJS attendue :
/// ```json
/// {
///   "accessToken": "eyJ...",
///   "refreshToken": "eyJ...",
///   "user": { "id": "...", "email": "...", ... }
/// }
/// ```
class AuthResponseDto {
  final String  accessToken;
  final String? refreshToken;
  final UserDto user;

  const AuthResponseDto({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken:  json['accessToken']  as String,
      refreshToken: json['refreshToken'] as String?,
      user:         UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// DTO représentant un utilisateur tel que renvoyé par le backend.
class UserDto {
  final String       id;
  final String       email;
  final String       firstName;
  final String       lastName;
  final String?      avatarUrl;
  final List<String> roles;
  final String       createdAt;

  const UserDto({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.roles,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id:        json['id']        as String,
      email:     json['email']     as String,
      firstName: json['firstName'] as String? ?? '',
      lastName:  json['lastName']  as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      roles: (json['roles'] as List<dynamic>? ?? ['user']).cast<String>(),
      createdAt: json['createdAt'] as String? ??
          DateTime.now().toIso8601String(),
    );
  }

  /// Convertit le DTO vers l'entité du domaine.
  User toEntity() => User(
        id:        id,
        email:     email,
        firstName: firstName,
        lastName:  lastName,
        avatarUrl: avatarUrl,
        roles:     roles,
        createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      );
}
