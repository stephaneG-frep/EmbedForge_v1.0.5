/// Vérification des réponses aux défis « tape la commande ».
///
/// Les réponses attendues (`challengeAnswer`) sont de deux natures :
/// - une commande saisissable (`ls -lh /etc`, `q`, `Ctrl+Z (…)`) ;
/// - une explication en prose (« Le module est utilisé par… »), impossible à
///   deviner mot pour mot : on l'affiche alors en auto-évaluation.
class ChallengeAnswer {
  ChallengeAnswer._();

  static final _trailingNote = RegExp(r'\s*\([^()]*\)\s*$');
  static final _spaces = RegExp(r'\s+');
  static final _quotes = RegExp('[‘’“”"]');

  /// Retire une remarque finale entre parenthèses :
  /// `ping 192.168.1.1 (arrêter avec Ctrl+C)` → `ping 192.168.1.1`.
  static String canonical(String expected) =>
      expected.trim().replaceFirst(_trailingNote, '').trim();

  /// Minuscules, espaces compactés, guillemets unifiés, `sudo` initial ignoré.
  static String normalize(String s) {
    var out = s.trim().toLowerCase().replaceAll(_spaces, ' ');
    out = out.replaceAll(_quotes, "'");
    if (out.startsWith('sudo ')) out = out.substring(5);
    return out;
  }

  /// Vrai si la réponse attendue est une saisie (et non une phrase).
  /// [commandNames] : noms des commandes connues (premier mot accepté).
  static bool isTypable(String expected, Iterable<String> commandNames) {
    final canon = normalize(canonical(expected));
    if (canon.isEmpty) return false;
    final tokens = canon.split(' ');
    if (tokens.length == 1) return true;
    final known = {for (final n in commandNames) normalize(n).split(' ').first};
    return known.contains(tokens.first);
  }

  /// Correspondance stricte (après normalisation) avec la réponse attendue.
  static bool matches(String answer, String expected) {
    final a = normalize(answer);
    if (a.isEmpty) return false;
    return a == normalize(canonical(expected)) || a == normalize(expected);
  }
}
