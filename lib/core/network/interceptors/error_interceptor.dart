import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../error/failures.dart';

/// Mappe les [DioException] en [AppFailure] typées avant de les propager.
///
/// Centralise la gestion d'erreurs réseau pour éviter le boilerplate dans
/// chaque datasource. Les datasources peuvent ensuite faire :
/// ```dart
/// on DioException catch (e) {
///   throw e.error as AppFailure? ?? const UnknownFailure();
/// }
/// ```
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = _mapDioError(err);
    debugPrint('🔴 [ErrorInterceptor] ${err.requestOptions.path} → $failure');

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response:       err.response,
        type:           err.type,
        error:          failure,
        message:        failure.message,
      ),
    );
  }

  AppFailure _mapDioError(DioException err) {
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout     ||
      DioExceptionType.receiveTimeout  => const NetworkFailure(
          message: 'Délai de connexion dépassé. Réessayez.',
        ),
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.badResponse     => _mapStatusCode(
          err.response?.statusCode,
          err.response?.data,
        ),
      DioExceptionType.cancel          => const UnknownFailure(
          message: 'Requête annulée.',
        ),
      _                                => const UnknownFailure(),
    };
  }

  AppFailure _mapStatusCode(int? code, dynamic data) {
    final message = _extractMessage(data);
    return switch (code) {
      401 => UnauthorizedFailure(message: message ?? 'Non autorisé. Reconnectez-vous.'),
      403 => ForbiddenFailure(message: message ?? 'Accès interdit.'),
      404 => NotFoundFailure(message: message ?? 'Ressource introuvable.'),
      409 => ConflictFailure(message: message ?? 'Conflit de données.'),
      422 => ValidationFailure(message: message ?? 'Données invalides.'),
      _ when (code ?? 0) >= 500 => ServerFailure(
          message: message ?? 'Erreur serveur. Réessayez plus tard.',
          statusCode: code,
        ),
      _ => ServerFailure(
          message: message ?? 'Erreur inconnue.',
          statusCode: code,
        ),
    };
  }

  /// Extrait le champ `message` du corps JSON de réponse NestJS.
  /// NestJS retourne : `{ "statusCode": 4xx, "message": "...", "error": "..." }`
  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String) return msg;
      if (msg is List && msg.isNotEmpty) return msg.first as String?;
    }
    return null;
  }
}
