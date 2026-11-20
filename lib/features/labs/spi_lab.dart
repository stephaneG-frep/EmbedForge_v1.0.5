import 'dart:async';
import 'dart:math' as math;

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

    // Quatre fils espacés de 26 px ; chaque libellé est posé AU-DESSUS de son
    // fil (texte ≈ 12 px de haut) pour ne jamais être barré par un autre fil.
    const yMosi = 44.0, yMiso = 70.0, ySclk = 98.0, yCs = 124.0;
    const wires = [yMosi, yMiso, ySclk, yCs];
    const chipW = 76.0;
    const left = 14.0 + chipW;
    final right = size.width - 14 - chipW;
    final mid = (left + right) / 2;

    // Master (à gauche) et Slave (à droite), broches alignées sur les fils.
    _chip(
      canvas,
      const Rect.fromLTWH(14, 26, chipW, 110),
      'MASTER',
      AppColors.teal,
      wires,
    );
    _chip(
      canvas,
      Rect.fromLTWH(right, 26, chipW, 110),
      'SLAVE',
      AppColors.blue,
      wires,
    );

    canvas.drawLine(Offset(left, yMosi), Offset(right, yMosi), active);
    _label(canvas, 'MOSI →', mid, yMosi - 14);
    canvas.drawLine(Offset(left, yMiso), Offset(right, yMiso), active);
    _label(canvas, '← MISO', mid, yMiso - 14);

    // SCLK : signal carré (±5 px autour du fil).
    final path = Path()..moveTo(left, ySclk + 5);
    var high = false;
    for (var x = left; x < right; x += 9) {
      final y = ySclk + (high ? -5 : 5);
      path
        ..lineTo(x, y)
        ..lineTo(math.min(x + 9, right), y);
      high = !high;
    }
    canvas.drawPath(path, active);
    _label(canvas, 'SCLK $clock MHz', mid, ySclk - 19);

    canvas.drawLine(Offset(left, yCs), Offset(right, yCs), wire);
    _label(canvas, 'CS', mid, yCs - 14);

    // Registres sous le schéma.
    if (transferring) {
      _label(canvas, 'registre master', mid, 140);
      final bits = mosi.toRadixString(2).padLeft(8, '0');
      for (var i = 0; i < 8; i++) {
        _label(canvas, bits[i], mid - 63 + i * 18, 152);
      }
      _label(canvas, 'registre slave', mid, 164);
      final bits2 = miso.toRadixString(2).padLeft(8, '0');
      for (var i = 0; i < 8; i++) {
        _label(canvas, bits2[i], mid - 63 + i * 18, 176);
      }
    } else {
      _label(
        canvas,
        'Master = 0x${mosi.toRadixString(16).toUpperCase().padLeft(2, '0')}',
        mid,
        148,
      );
      _label(
        canvas,
        'Slave  = 0x${miso.toRadixString(16).toUpperCase().padLeft(2, '0')}',
        mid,
        168,
      );
    }
  }

  void _chip(
    Canvas canvas,
    Rect rect,
    String label,
    Color color,
    List<double> pins,
  ) {
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(9));
    canvas.drawRRect(r, Paint()..color = const Color(0xFF232C3B));
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = 1.6,
    );
    final pinPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 2;
    for (final y in pins) {
      canvas.drawLine(Offset(rect.left - 8, y), Offset(rect.left, y), pinPaint);
      canvas.drawLine(
        Offset(rect.right, y),
        Offset(rect.right + 8, y),
        pinPaint,
      );
    }
    _label(canvas, label, rect.center.dx, rect.center.dy - 6);
  }

  TextPainter _painter(String t) => TextPainter(
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

  /// Texte centré horizontalement sur [cx].
  void _label(Canvas canvas, String t, double cx, double top) {
    final tp = _painter(t);
    tp.paint(canvas, Offset(cx - tp.width / 2, top));
  }

  @override
  bool shouldRepaint(covariant _SpiPainter old) =>
      old.transferring != transferring ||
      old.mosi != mosi ||
      old.miso != miso ||
      old.clock != clock;
}
