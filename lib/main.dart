import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/theme.dart';
import 'data/data_loader.dart';
import 'services/crash_reporter.dart';
import 'services/storage_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CrashReporter.boot();

  final storage = StorageService();
  final repo = ContentRepository();
  // Deux étapes indépendantes : l'échec de l'une n'empêche pas l'autre.
  try {
    await storage.init();
  } catch (e, st) {
    // StorageService bascule alors sur un stockage en mémoire.
    CrashReporter.log('DART_STORAGE_ERROR $e\n$st');
  }
  try {
    await repo.load();
  } catch (e, st) {
    CrashReporter.log('DART_CONTENT_ERROR $e\n$st');
  }

  // Autodiagnostic : état du chargement consigné dans le journal privé
  // de l'application (jamais dans le presse-papiers ni en stockage public).
  CrashReporter.log(
    'DART_CONTENT courses=${repo.courses.length} '
    'cmds=${repo.commands.length} '
    'quizzes=${repo.quizzes.length} '
    'projects=${repo.projects.length} '
    'glossary=${repo.glossary.length} '
    'cheats=${repo.cheatSheets.length} '
    'roadmap=${repo.roadmap.length} '
    'badges=${repo.badges.length} '
    'loaded=${repo.loaded}',
  );

  // Portrait (usage principal sur smartphone) et paysage autorisés ;
  // le portrait inversé est exclu.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(EmbedForgeApp(storage: storage, repo: repo));
  CrashReporter.log('DART_UI_READY');
}

class EmbedForgeApp extends StatelessWidget {
  final StorageService storage;
  final ContentRepository repo;

  const EmbedForgeApp({super.key, required this.storage, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppState(storage: storage, repo: repo),
        ),
        Provider<ContentRepository>.value(value: repo),
      ],
      child: Consumer<AppState>(
        builder: (context, state, _) => MaterialApp(
          title: 'EmbedForge',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: state.theme,
          // Taille du texte choisie dans Paramètres, appliquée par-dessus le
          // réglage d'accessibilité du système (qui reste respecté).
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            final system = mq.textScaler.scale(1.0);
            return MediaQuery(
              data: mq.copyWith(
                textScaler: TextScaler.linear(system * state.fontScale),
              ),
              child: child!,
            );
          },
          home: const AppShell(),
        ),
      ),
    );
  }
}
