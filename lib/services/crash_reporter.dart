import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Journal de diagnostic hors-ligne : envoie des lignes horodatées vers le
/// canal natif qui les écrit dans le stockage privé de l'application
/// (`files/embedforge_crash.log`, taille plafonnée, inaccessible aux autres
/// applications). Facultatif — tout échec est silencieux.
class CrashReporter {
  static const MethodChannel _channel = MethodChannel('embedforge/diagnostics');

  static bool _registered = false;

  /// Nom de version réel (informations du paquet Android).
  static Future<String> version() async {
    try {
      final v = await _channel.invokeMethod<String>('version');
      return v ?? '?';
    } catch (_) {
      return '?';
    }
  }

  /// Installe les garde-fous globaux (peut être appelé plusieurs fois).
  static void install() {
    if (_registered) return;
    _registered = true;

    FlutterError.onError = (details) {
      final text = _format('DART_FLUTTER', details.exception, details.stack);
      log(text);
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      log(_format('DART_PLATFORM', error, stack));
      return true;
    };
  }

  static String _format(String tag, Object? error, StackTrace? stack) {
    final buf = StringBuffer('$tag ${error ?? '(unknown)'}');
    if (stack != null) {
      final lines = stack.toString().split('\n');
      for (var i = 0; i < lines.length && i < 10; i++) {
        buf.write('\n  ${lines[i]}');
      }
    }
    return buf.toString();
  }

  /// Envoie une ligne, sans jamais bloquer l'interface ni lever d'erreur.
  static void log(String text) {
    try {
      // Erreur asynchrone (canal absent, moteur détaché…) : ignorée aussi.
      _channel.invokeMethod<void>('log', text).catchError((Object _) {});
    } catch (_) {}
  }

  static Future<void> boot() async {
    install();
    log('DART_BOOT pid=${DateTime.now().millisecondsSinceEpoch}');
  }
}
