import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../services/crash_reporter.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';

/// Fiche « À propos ».
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '…';

  @override
  void initState() {
    super.initState();
    CrashReporter.version().then((v) {
      if (mounted) setState(() => _version = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppState>().repo;
    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.developer_board,
                    color: AppColors.blue,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'EmbedForge',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                ),
                Text(
                  'v$_version',
                  style: const TextStyle(
                    color: AppColors.inkSoft,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Apprendre le développement Linux embarqué de zéro jusqu’au '
                  'niveau professionnel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SectionHeader(
            title: 'Technologies',
            icon: Icons.build_outlined,
          ),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _line('Flutter stable', 'UI multiplateforme · Material 3'),
                _line('Dart', 'null safety'),
                _line('SharedPreferences', 'stockage local des progrès'),
                _line('Assets JSON', 'cours, quiz, projets, glossaire…'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SectionHeader(
            title: 'Contenu hors-ligne',
            icon: Icons.cloud_off,
          ),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${repo.courses.length} cours · '
                  '${repo.commands.length} commandes · '
                  '${repo.quizzes.length} quiz · '
                  '${repo.projects.length} projets · '
                  '${repo.badges.length} badges',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tout le contenu est embarqué dans l’application. Aucun compte, '
                  'aucune base distante, aucun abonnement : tu apprends où tu veux, '
                  'même en avion.',
                  style: const TextStyle(fontSize: 12.8, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SectionHeader(title: 'Licence du contenu', icon: Icons.balance),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: const Text(
              'Application pédagogique à but éducatif. Les commandes, exemples '
              'et architectures Linux cités (Raspberry Pi, ARM, Buildroot, Yocto…) '
              'appartiennent à leurs auteurs et communautés respectives.',
              style: TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              k,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          Expanded(child: Text(v, style: const TextStyle(fontSize: 12.8))),
        ],
      ),
    );
  }
}
