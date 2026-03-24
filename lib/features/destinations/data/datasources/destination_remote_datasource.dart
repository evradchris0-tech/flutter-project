import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/failures.dart';
import '../dto/destination_dto.dart';

/// Contrat de la source de données distante.
abstract interface class IDestinationRemoteDataSource {
  /// Récupère toutes les destinations depuis l'API NestJS.
  Future<List<DestinationDto>> getDestinations();

  /// Récupère une destination par ID depuis l'API NestJS.
  Future<DestinationDto> getDestinationById(String id);
}

/// Implémentation Dio — communique avec le backend NestJS.
///
/// Gestion d'erreurs : l'[ErrorInterceptor] a déjà mappé les [DioException]
/// en [AppFailure]. On re-lance l'[AppFailure] directement.
class DestinationRemoteDataSource implements IDestinationRemoteDataSource {
  final Dio _dio;

  const DestinationRemoteDataSource(this._dio);

  @override
  Future<List<DestinationDto>> getDestinations() async {
    try {
      final response = await _dio.get(ApiConstants.destinations);
      final data = response.data as List<dynamic>;
      return data
          .cast<Map<String, dynamic>>()
          .map(DestinationDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw e.error as AppFailure? ?? const NetworkFailure();
    } catch (e) {
      debugPrint('⚠️ DestinationRemoteDataSource.getDestinations: $e');
      throw const NetworkFailure();
    }
  }

  @override
  Future<DestinationDto> getDestinationById(String id) async {
    try {
      final response =
          await _dio.get('${ApiConstants.destinations}/$id');
      return DestinationDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.error as AppFailure? ?? const NetworkFailure();
    }
  }
}
