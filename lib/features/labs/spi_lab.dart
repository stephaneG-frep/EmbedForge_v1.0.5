import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../widgets/app_card.dart';
import '../../widgets/code_block.dart';
import '../../widgets/common.dart';

/// Un coup d'horloge : le MSB du master part sur MOSI, celui du slave sur
/// MISO ; chacun décale à gauche et récupère le bit reçu en LSB.
(int, int) spiClock(int master, int slave) {
  final mosiBit = (master >> 7) & 1;
  final misoBit = (slave >> 7) & 1;
  return (((master << 1) | misoBit) & 0xFF, ((slave << 1) | mosiBit) & 0xFF);
}

/// SPI Lab : transfert MOSI / MISO entre master et slave avec horloge.
class SpiLab extends StatefulWidget {
  const SpiLab({super.key});

  @override
  State<SpiLab> createState() => _SpiLabState();
}

class _SpiLabState extends State<SpiLab> {
  int _clock = 4; // MHz
  // Registres à décalage 8 bits du master et du slave (SPI mode 0, MSB first).
  int _master = 0x35; // 0b00110101 : octet que le master envoie
  int _slave = 0x7A; // 0b01111010 : octet que le slave renvoie
  bool _transferring = false;
  String? _lastResult;

  static String _hex(int v) =>
      '0x${v.toRadixString(16).padLeft(2, '0').toUpperCase()}';

  Future<void> _transfer() async {
    if (_transferring) return;
    final sent = _master;
    final reply = _slave;
    setState(() {
      _transferring = true;
      _lastResult = null;
    });
    final stepDuration = Duration(milliseconds: (6000 / _clock).round());
    for (var i = 0; i < 8; i++) {
      await Future.delayed(stepDuration);
      if (!mounted) return;
      final (m, sl) = spiClock(_master, _slave);
      setState(() {
        _master = m;
        _slave = sl;
      });
      await Future.delayed(stepDuration);
      if (!mounted) return;
    }
    setState(() {
      _lastResult =
          'Échange full-duplex terminé (8 coups d’horloge) :\n'
          'MOSI : master → slave  ${_hex(sent)}  (le slave contient ${_hex(_slave)})\n'
          'MISO : slave → master  ${_hex(reply)}  (le master contient ${_hex(_master)})';
      _transferring = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const LabHeader(
          title: 'SPI Lab',
          subtitle: 'Serial Peripheral Interface',
          icon: Icons.compare_arrows,
          color: AppColors.teal,
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            children: [
              SizedBox(
                height: 190,
                child: CustomPaint(
                  size: const Size(double.infinity, 190),
                  painter: _SpiPainter(
                    transferring: _transferring,
                    mosi: _master,
                    miso: _slave,
                    clock: _clock,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final m in [1, 4, 8])
                    ChoiceChip(
                      label: Text('$m MHz'),
                      selected: _clock == m,
                      onSelected: (_) => setState(() => _clock = m),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _transferring ? null : _transfer,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                ),
                icon: Icon(
                  _transferring ? Icons.hourglass_top : Icons.play_arrow,
                  size: 18,
                ),
                label: Text(
                  _transferring ? 'Transfert en cours' : 'Lancer un transfert',
                ),
              ),
              if (_lastResult != null) ...[
                const SizedBox(height: 12),
                CodeBlock(code: _lastResult!, label: 'résultat'),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Les 4 fils du SPI', icon: Icons.functions),
        TableSectionWidget(),
        const SizedBox(height: 10),
        Callout(
          text:
              'Le SPI est synchrone et full-duplex : pendant que le master envoie '
              'un bit sur MOSI, le slave renvoie un bit sur MISO. On choisit le '
              'périphérique grâce à la ligne CS (Chip Select) mise à LOW.',
          color: AppColors.orange,
          icon: Icons.compare_arrows,
          title: 'Full-duplex',
        ),
        const SizedBox(height: 10),
        Text(
          'Contrairement à I²C, le SPI n’a pas d’adresse : chaque périphérique '
          'possède sa propre ligne CS. C’est rapide (dizaines de MHz) mais il '
          'utilise plus de fils.',
          style: const TextStyle(fontSize: 13.3, height: 1.45),
        ),
        const SizedBox(height: 8),
        CodeBlock(
          label: 'Exemple Bus C (conceptuel)',
          code: '''
// Activer le chip select
gpio_set(PIN_CS, 0);
// Envoyer un octet, recevoir un octet
uint8_t rx = spi_transfer(bus, 0x35);
// Desactiver le chip select
gpio_set(PIN_CS, 1);''',
        ),
      ],
    );
  }
}

class TableSectionWidget extends StatelessWidget {
  const TableSectionWidget({super.key});
  @override
  Widget build(BuildContext context) {
    const rows = [
      ['MOSI', 'Master Out Slave In — données master → slave'],
      ['MISO', 'Master In Slave Out — données slave → master'],
      ['SCLK', 'Horloge générée par le master'],
      ['CS', 'Chip Select — actif bas, sélectionne un slave'],
    ];
    return Column(
      children: [
        for (final row in rows)
          AppCard(
            flat: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2A3646).withValues(alpha: 0.6)
                        : const Color(0xFFEDF1F6),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 68,
                    child: Text(
                      row[0],
                      style: const TextStyle(
                        fontFamily: 'MonoTech',
                        color: AppColors.teal,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(row[1], style: const TextStyle(fontSize: 12.8)),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SpiPainter extends CustomPainter {
  final bool transferring;
  final int mosi;
  final int miso;
  final int clock;

  _SpiPainter({
    required this.transferring,
    required this.mosi,
    required this.miso,
    required this.clock,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wire = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFF5A6675);
    final active = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = transferring ? AppColors.teal : wire.color;

    // Master (à gauche) et Slave (à droite)
    _chip(
      canvas,
      const Rect.fromLTWH(14, 26, 96, 62),
      'MASTER',
      AppColors.teal,
    );
    _chip(
      canvas,
      Rect.fromLTWH(size.width - 132, 26, 110, 62),
      'SLAVE',
      AppColors.blue,
    );

    const yStart = 38.0;
    // MOSI
    canvas.drawLine(
      Offset(110, yStart),
      Offset(size.width - 132, yStart),
      active,
    );
    _text(canvas, 'MOSI', Offset(size.width / 2 - 22, yStart - 12));
    // MISO
    canvas.drawLine(
      Offset(110, yStart + 22),
      Offset(size.width - 132, yStart + 22),
      active,
    );
    _text(canvas, 'MISO', Offset(size.width / 2 - 22, yStart + 10));
    // SCLK : sinusoïde
    final path = Path();
    for (var x = 110.0; x <= size.width - 132; x += 4) {
      final v = (x / 18).floor();
      final y = yStart + 44 + (v.isEven ? -6 : 6);
      if (x == 110) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, active);
    _text(canvas, 'SCLK  $clock MHz', Offset(size.width / 2 - 42, yStart + 40));
    // CS
    canvas.drawLine(
      Offset(110, yStart + 68),
      Offset(size.width - 132, yStart + 68),
      wire,
    );
    _text(canvas, 'CS', Offset(size.width / 2 - 9, yStart + 58));

    // Bits sous les lignes pendant transfert
    if (transferring) {
      final bits = mosi.toRadixString(2).padLeft(8, '0');
      for (var i = 0; i < 8; i++) {
        final x = 120.0 + i * (18.0);
        _text(canvas, bits[i], Offset(x, 130));
      }
      _text(canvas, 'registre master', Offset(120, 118));
      final bits2 = miso.toRadixString(2).padLeft(8, '0');
      for (var i = 0; i < 8; i++) {
        final x = 120.0 + i * 18.0;
        _text(canvas, bits2[i], Offset(x, 156));
      }
      _text(canvas, 'registre slave', Offset(120, 144));
    } else {
      _text(
        canvas,
        'Master = 0x${mosi.toRadixString(16).toUpperCase().padLeft(2, '0')}',
        Offset(120, 132),
      );
      _text(
        canvas,
        'Slave  = 0x${miso.toRadixString(16).toUpperCase().padLeft(2, '0')}',
        Offset(120, 156),
      );
    }
  }

  void _chip(Canvas canvas, Rect rect, String label, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(9)),
      Paint()..color = const Color(0xFF232C3B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(9)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = 1.6,
    );
    for (final y in [30.0, 46.0, 62.0, 78.0]) {
      final pinPaint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.left - 14, y - 4),
        pinPaint,
      );
      canvas.drawLine(
        Offset(rect.right, y),
        Offset(rect.right + 14, y - 4),
        pinPaint,
      );
    }
    _text(canvas, label, Offset(rect.left + 12, rect.top + 24));
  }

  void _text(Canvas canvas, String t, Offset p) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: const TextStyle(
          color: Color(0xFFAEB8C6),
          fontSize: 10,
          fontFamily: 'MonoTech',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, p);
  }

  @override
  bool shouldRepaint(covariant _SpiPainter old) =>
      old.transferring != transferring ||
      old.mosi != mosi ||
      old.miso != miso ||
      old.clock != clock;
}
