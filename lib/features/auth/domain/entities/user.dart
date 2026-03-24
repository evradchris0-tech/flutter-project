import 'package:equatable/equatable.dart';

/// Entité du domaine : représente l'utilisateur authentifié.
///
/// Immuable + Equatable → les providers Riverpod reconstruisent
/// uniquement quand les données changent réellement.
class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final List<String> roles;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.roles,
    required this.createdAt,
  });

  // ── Computed Properties ───────────────────────────────────────────────────

  String get fullName    => '$firstName $lastName';
  String get initials    => '${firstName[0]}${lastName[0]}'.toUpperCase();
  bool   get isAdmin     => roles.contains('admin');
  bool   get isGuest     => false;

  // ── Equatable ─────────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [
        id, email, firstName, lastName, avatarUrl, roles, createdAt,
      ];

  // ── copyWith ──────────────────────────────────────────────────────────────

  User copyWith({
    String?   id,
    String?   email,
    String?   firstName,
    String?   lastName,
    String?   avatarUrl,
    List<String>? roles,
    DateTime? createdAt,
  }) {
    return User(
      id:        id        ?? this.id,
      email:     email     ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName:  lastName  ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roles:     roles     ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email, roles: $roles)';
}

/// Représente un utilisateur non connecté (Guest pattern).
///
/// Evite les null checks dans la couche présentation.
class GuestUser extends User {
  GuestUser()
      : super(
          id:        'guest',
          email:     '',
          firstName: 'Visiteur',
          lastName:  '',
          roles:     const [],
          createdAt: DateTime(2024),
        );

  @override
  bool get isGuest => true;
}
