// NOTE : Stub du service de notifications — flutter_local_notifications retiré
// car la bibliothèque de désucrerie (desugar_jdk_libs) requiert dl.google.com
// qui est inaccessible depuis ce réseau.
// Le feedback utilisateur est assuré par des SnackBars dans detail_screen.dart.

class NotificationService {
  NotificationService._();

  static Future<void> init() async {}

  static Future<void> showVisitReminder({
    required int id,
    required String destinationName,
    required String region,
  }) async {}

  static Future<void> cancelAll() async {}
}
