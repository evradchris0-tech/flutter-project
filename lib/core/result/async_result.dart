import '../error/failures.dart';

/// Représente le cycle de vie complet d'une opération asynchrone.
///
/// Implémente le **Segmented State Pattern** (DelayedResult<T>) :
///   • [Idle]    — état initial, aucune opération lancée.
///   • [Loading] — opération en cours.
///   • [Success] — opération terminée avec succès, contient [data].
///   • [Failure] — opération échouée, contient un [AppFailure] typé.
///
/// Avantages vs AsyncValue de Riverpod :
///   - Indépendant du framework : utilisable dans la couche domaine et data.
///   - Failure typée (pas un simple Object) → exhaustivité dans les switch.
///   - État [Idle] explicite → pas d'ambiguïté entre "pas encore chargé" et "chargement".
///
/// Exemple d'utilisation :
/// ```dart
/// final result = await getDestinations();
/// return switch (result) {
///   Idle()    => const Text('Appuyez pour charger'),
///   Loading() => const CircularProgressIndicator(),
///   Success(data: final dests) => DestinationList(dests),
///   Failure(failure: final f)  => ErrorView(f.message),
/// };
/// ```
sealed class AsyncResult<T> {
  const AsyncResult();

  // ── Accesseurs rapides ────────────────────────────────────────────────────

  bool get isIdle    => this is Idle<T>;
  bool get isLoading => this is Loading<T>;
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  /// Renvoie la donnée si [Success], sinon null.
  T? get dataOrNull => switch (this) {
    Success<T>(data: final d) => d,
    _ => null,
  };

  /// Renvoie l'échec si [Failure], sinon null.
  AppFailure? get failureOrNull => switch (this) {
    Failure<T>(failure: final f) => f,
    _ => null,
  };

  // ── Transformations ───────────────────────────────────────────────────────

  /// Applique [transform] sur la donnée si [Success].
  AsyncResult<R> map<R>(R Function(T data) transform) => switch (this) {
    Success<T>(data: final d) => Success(transform(d)),
    Loading<T>()              => Loading<R>(),
    Idle<T>()                 => Idle<R>(),
    Failure<T>(failure: final f) => Failure<R>(f),
  };

  /// Equivalent à flatMap : chaîne des opérations asynchrones.
  AsyncResult<R> flatMap<R>(AsyncResult<R> Function(T data) transform) =>
      switch (this) {
        Success<T>(data: final d)    => transform(d),
        Loading<T>()                 => Loading<R>(),
        Idle<T>()                    => Idle<R>(),
        Failure<T>(failure: final f) => Failure<R>(f),
      };

  // ── Pattern matching helper ───────────────────────────────────────────────

  R when<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(AppFailure failure) failure,
  }) =>
      switch (this) {
        Idle<T>()                    => idle(),
        Loading<T>()                 => loading(),
        Success<T>(data: final d)    => success(d),
        Failure<T>(failure: final f) => failure(f),
      };

  R maybeWhen<R>({
    R Function()? idle,
    R Function()? loading,
    R Function(T data)? success,
    R Function(AppFailure failure)? failure,
    required R Function() orElse,
  }) =>
      switch (this) {
        Idle<T>()                    => idle?.call() ?? orElse(),
        Loading<T>()                 => loading?.call() ?? orElse(),
        Success<T>(data: final d)    => success?.call(d) ?? orElse(),
        Failure<T>(failure: final f) => failure?.call(f) ?? orElse(),
      };
}

// ── Variantes concrètes ───────────────────────────────────────────────────────

/// État initial — aucune opération lancée.
final class Idle<T> extends AsyncResult<T> {
  const Idle();
}

/// Opération en cours.
final class Loading<T> extends AsyncResult<T> {
  const Loading();
}

/// Opération réussie.
final class Success<T> extends AsyncResult<T> {
  final T data;
  const Success(this.data);
}

/// Opération échouée avec un [AppFailure] typé.
final class Failure<T> extends AsyncResult<T> {
  final AppFailure failure;
  const Failure(this.failure);
}
