import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../state/app_state.dart';
import '../../widgets/app_card.dart';
import 'binary_lab.dart';
import 'bitwise_lab.dart';
import 'boot_lab.dart';
import 'gpio_lab.dart';
import 'i2c_lab.dart';
import 'memory_lab.dart';
import 'spi_lab.dart';
import 'uart_lab.dart';

class LabEntry {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget Function() builder;

  const LabEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });
}

final List<LabEntry> labEntries = [
  LabEntry(
    id: 'gpio',
    title: 'GPIO Lab',
    subtitle: 'LED, résistance et bouton',
    icon: Icons.bolt,
    color: AppColors.green,
    builder: () => const GpioLab(),
  ),
  LabEntry(
    id: 'uart',
    title: 'UART Lab',
    subtitle: 'Échange série TX / RX',
    icon: Icons.swap_horiz,
    color: AppColors.blue,
    builder: () => const UartLab(),
  ),
  LabEntry(
    id: 'i2c',
    title: 'I²C Lab',
    subtitle: 'Scanner le bus',
    icon: Icons.hub,
    color: AppColors.purple,
    builder: () => const I2cLab(),
  ),
  LabEntry(
    id: 'spi',
    title: 'SPI Lab',
    subtitle: 'MOSI / MISO / CLK / CS',
    icon: Icons.compare_arrows,
    color: AppColors.teal,
    builder: () => const SpiLab(),
  ),
  LabEntry(
    id: 'boot',
    title: 'Linux Boot Lab',
    subtitle: 'La séquence de démarrage',
    icon: Icons.power,
    color: AppColors.orange,
    builder: () => const BootLab(),
  ),
  LabEntry(
    id: 'memory',
    title: 'Memory Lab',
    subtitle: 'Stack, heap et adresses',
    icon: Icons.memory,
    color: AppColors.yellow,
    builder: () => const MemoryLab(),
  ),
  LabEntry(
    id: 'binary',
    title: 'Binary Lab',
    subtitle: 'Binaire / décimal / hex',
    icon: Icons.tag,
    color: AppColors.pink,
    builder: () => const BinaryLab(),
  ),
  LabEntry(
    id: 'bitwise',
    title: 'Bitwise Lab',
    subtitle: 'Opérations sur les bits',
    icon: Icons.settings_ethernet,
    color: AppColors.blue,
    builder: () => const BitwiseLab(),
  ),
];

/// Espace « Lab » : réseau de laboratoires interactifs.
class LabsScreen extends StatelessWidget {
  const LabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Embedded Lab'), centerTitle: false),
      body: Consumer<AppState>(
        builder: (context, state, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10151C), Color(0xFF1B3A55)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(kRadius),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Simulateurs interactifs',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Expérimentez GPIO, UART, I²C, SPI, le boot Linux, la mémoire\net le binaire, sans aucun matériel. 100 % hors-ligne.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.98,
              children: [
                for (final entry in labEntries)
                  _LabTile(entry: entry, used: state.isLabUsed(entry.id)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LabTile extends StatelessWidget {
  final LabEntry entry;
  final bool used;

  const _LabTile({required this.entry, required this.used});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => _LabScaffold(entry: entry)));
      },
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: entry.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(entry.icon, color: entry.color, size: 22),
              ),
              const Spacer(),
              if (used)
                Icon(Icons.check_circle, size: 17, color: AppColors.green),
            ],
          ),
          const Spacer(),
          Text(
            entry.title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            entry.subtitle,
            style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LabScaffold extends StatelessWidget {
  final LabEntry entry;
  const _LabScaffold({required this.entry});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    state.markLabUsed(entry.id);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(entry.icon, color: entry.color, size: 20),
            const SizedBox(width: 9),
            Text(entry.title),
          ],
        ),
      ),
      body: entry.builder(),
    );
  }
}
