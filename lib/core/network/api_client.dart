import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// Factory qui construit et configure l'instance [Dio] partagée.
///
/// Architecture des intercepteurs (ordre important, Dio les applique en LIFO pour onError) :
///   1. [AuthInterceptor]  — injecte le Bearer token.
///   2. [ErrorInterceptor] — mappe les erreurs HTTP en [AppFailure].
///   3. [LogInterceptor]   — logs détaillés en développement uniquement.
class ApiClient {
  ApiClient._();

  static Dio create({
    required AuthInterceptor authInterceptor,
    required ErrorInterceptor errorInterceptor,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl:        ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout:    ApiConstants.sendTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept':       'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.addAll([
      authInterceptor,
      errorInterceptor,
      // Logs uniquement en debug — désactivés en release pour les perfs & la sécurité.
      if (kDebugMode)
        LogInterceptor(
          requestBody:  true,
          responseBody: true,
          error:        true,
          logPrint: (o) => debugPrint('🌐 [DIO] $o'),
        ),
    ]);

    return dio;
  }
}
