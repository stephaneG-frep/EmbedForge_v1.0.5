import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../widgets/app_card.dart';
import '../../widgets/common.dart';

/// Boot Lab : séquence de démarrage Linux cliquable.
class BootLab extends StatefulWidget {
  const BootLab({super.key});

  @override
  State<BootLab> createState() => _BootLabState();
}

class _BootLabState extends State<BootLab> {
  int? _selected;

  static const steps = <_BootStep>[
    _BootStep(
      title: 'Power ON',
      icon: 'power',
      color: AppColors.red,
      desc:
          'L’alimentation stabilise les tensions (3,3 V, 5 V…). Les oscillateurs '
          'génèrent les horloges, puis la puce de reset libère les processeurs : le '
          'programme commence immédiatement à l’adresse d’amorçage de la boot ROM.',
    ),
    _BootStep(
      title: 'Boot ROM',
      icon: 'memory',
      color: AppColors.orange,
      desc:
          'Petite zone en silicium dans le SoC, non modifiable. Sa tâche : '
          'initialiser le matériel minimal (RAM, horloge) puis trouver et lancer '
          'le bootloader stocké dans la flash (eMMC, SPI NOR, SD).',
    ),
    _BootStep(
      title: 'Bootloader',
      icon: 'sd',
      color: AppColors.yellow,
      desc:
          'U-Boot par exemple. Il initialise la DRAM, configure les ports, '
          'charge les fichiers depuis le stockage ou le réseau, puis transfère '
          'le contrôle au noyau Linux en lui passant le device tree (DTB).',
    ),
    _BootStep(
      title: 'Linux Kernel',
      icon: 'kernel',
      color: AppColors.green,
      desc:
          'Décompressé en mémoire, il démarre à bas niveau : gestion de la '
          'mémoire, scheduler, drivers. Il lit le device tree pour connaître le '
          'matériel présent, puis monte le true root filesystem.',
    ),
    _BootStep(
      title: 'Device Tree',
      icon: 'details',
      color: AppColors.teal,
      desc:
          'Description du matériel sous forme de données : chaque périphérique '
          '(GPIO, UART, I²C…) est un nœud avec adressage, interruptions et '
          'driver associé. Le kernel s’adapte sans recompilation.',
    ),
    _BootStep(
      title: 'Root filesystem',
      icon: 'storage',
      color: AppColors.blue,
      desc:
          'Le systèmes de fichiers racine (rootfs) est monté en lecture seule '
          'puis remonté. Il contient /bin, /lib, /etc… Les scripts d’init sont '
          'exécutés dans l’ordre de boot.',
    ),
    _BootStep(
      title: 'systemd / init',
      icon: 'hub',
      color: AppColors.purple,
      desc:
          'Le PID 1 lance les services : systemd lance unités en parallèle '
          '(réseau, journaux, daemons applicatifs). Sur systèmes plus simples, '
          'busybox init exécute /etc/inittab séquentiellement.',
    ),
    _BootStep(
      title: 'Application',
      icon: 'rocket',
      color: AppColors.green,
      desc:
          'Votre programme embarqué démarre : service de capteurs, application '
          'MQTT, interface… Le système est prêt à remplir son rôle.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const LabHeader(
          title: 'Linux Boot Lab',
          subtitle: 'Cliquez chaque étape du démarrage',
          icon: Icons.power,
          color: AppColors.orange,
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < steps.length; i++) _step(i),
        if (_selected != null) ...[
          const SizedBox(height: 12),
          AppCard(
            color: steps[_selected!].color.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.14
                  : 0.08,
            ),
            borderColor: steps[_selected!].color.withValues(alpha: 0.6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      steps[_selected!].iconData,
                      color: steps[_selected!].color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      steps[_selected!].title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  steps[_selected!].desc,
                  style: const TextStyle(fontSize: 13.4, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _step(int index) {
    final step = steps[index];
    final selected = _selected == index;
    final color = step.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _selected = selected ? null : index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: selected || _selected != null && _selected! < index
                    ? color.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.16
                            : 0.1,
                      )
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: selected ? color : color.withValues(alpha: 0.45),
                  width: selected ? 1.8 : 1.1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(step.iconData, size: 17, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${index + 1}.  ${step.title}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.8,
                      ),
                    ),
                  ),
                  Icon(
                    selected ? Icons.expand_more : Icons.chevron_right,
                    color: AppColors.inkSoft,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              width: 2,
              height: 10,
              color: color.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _BootStep {
  final String title;
  final String icon;
  final Color color;
  final String desc;
  const _BootStep({
    required this.title,
    required this.icon,
    required this.color,
    required this.desc,
  });

  IconData get iconData {
    switch (icon) {
      case 'power':
        return Icons.power;
      case 'memory':
        return Icons.memory;
      case 'sd':
        return Icons.sd_card;
      case 'kernel':
        return Icons.settings_suggest;
      case 'details':
        return Icons.grid_view;
      case 'storage':
        return Icons.storage;
      case 'hub':
        return Icons.hub;
      case 'rocket':
        return Icons.rocket_launch;
      default:
        return Icons.circle;
    }
  }
}
