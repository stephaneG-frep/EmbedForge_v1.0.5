import 'dart:ui' show Color;

/// Utilitaires de conversion (binaire / hexadécimal / décimal).
class NumberTools {
  NumberTools._();

  static String toBinary(int value, {int bits = 8}) {
    final raw = value.toRadixString(2).padLeft(bits, '0');
    return raw.length > bits ? raw.substring(raw.length - bits) : raw;
  }

  static String toHex(int value, {int digits = 2}) =>
      '0x${value.toRadixString(16).toUpperCase().padLeft(digits, '0')}';

  static int fromBinary(String bin) => int.tryParse(bin, radix: 2) ?? 0;

  static List<int> decimalDigits(int value) {
    return List.generate(
      value.toRadixString(10).length,
      (i) => int.parse(value.toRadixString(10)[i]),
    );
  }

  /// Masque de bits en partant du bit le plus significatif (MSB à gauche).
  static int msbMask(int bits) => 1 << (bits - 1);

  /// Puissance de 2 la plus proche au-dessus (utilisée en UI).
  static int nextPowerOfTwo(int v) {
    var x = 1;
    while (x < v) {
      x <<= 1;
    }
    return x;
  }
}

/// Formateurs divers.
class Fmt {
  Fmt._();

  static String xp(int value) =>
      value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k xp' : '$value xp';

  static String percent(double value) => '${(value * 100).round()} %';

  static String duration(int minutes) => minutes < 60
      ? '$minutes min'
      : '${minutes ~/ 60}h${(minutes % 60) == 0 ? '' : ' ${minutes % 60}'}';

  static String bytes(int n) {
    if (n < 1024) return '$n B';
    if (n < 1024 * 1024) return '${(n / 1024).toStringAsFixed(1)} KB';
    if (n < 1024 * 1024 * 1024) {
      return '${(n / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(n / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String firstUpper(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// Normalisation pour la recherche (accent-insensitive, lower-case).
const _accentMap = {
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'î': 'i',
  'ï': 'i',
  'ô': 'o',
  'ö': 'o',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'ñ': 'n',
  'À': 'a',
  'Â': 'a',
  'Ä': 'a',
  'É': 'e',
  'È': 'e',
  'Ê': 'e',
  'Ë': 'e',
  'Î': 'i',
  'Ï': 'i',
  'Ô': 'o',
  'Ö': 'o',
  'Ù': 'u',
  'Û': 'u',
  'Ü': 'u',
  'Ç': 'c',
  'Ñ': 'n',
};

String normalizeSearch(String input) {
  final buffer = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(_accentMap[ch] ?? ch);
  }
  return buffer.toString();
}

/// ID stable : slug d'un texte.
String slugify(String input) {
  final normalized = normalizeSearch(input);
  final cleaned = normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  return cleaned.replaceAll(RegExp(r'^_+|_+$'), '');
}

/// Clamp 0..1
double clamp01(double v) => v.clamp(0.0, 1.0).toDouble();

/// Exponentielle douce pour les barres de progression.
double easeOutCubic(double t) {
  final u = 1 - clamp01(t);
  return 1 - u * u * u;
}

bool isDark(Color c) => c.computeLuminance() < 0.5;

/// Arrondi de math utilisé partout.
double round2(double v) => (v * 100).roundToDouble() / 100;
