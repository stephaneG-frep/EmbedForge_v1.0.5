import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../widgets/app_card.dart';
import '../../widgets/code_block.dart';
import '../../widgets/common.dart';

/// I²C Lab : scanner de bus avec appareils virtuels.
class I2cLab extends StatefulWidget {
  const I2cLab({super.key});

  @override
  State<I2cLab> createState() => _I2cLabState();
}

class _I2cLabState extends State<I2cLab> {
  bool _scanning = false;
  List<_I2cDevice>? _found;
  String? _selectedAddress;

  static const _devices = <_I2cDevice>[
    _I2cDevice(
      address: '0x3C',
      name: 'OLED Display',
      type: 'Écran',
      value: '128×64 px',
    ),
    _I2cDevice(
      address: '0x48',
      name: 'Temperature sensor',
      type: 'Capteur',
      value: '24,6 °C',
    ),
    _I2cDevice(
      address: '0x68',
      name: 'RTC',
      type: 'Horloge',
      value: '14:32:05',
    ),
    _I2cDevice(
      address: '0x29',
      name: 'Proximity / ALS',
      type: 'Capteur',
      value: 'Lum. 412 lux',
    ),
    _I2cDevice(
      address: '0x76',
      name: 'Barometer BMP280',
      type: 'Capteur',
      value: '1013 hPa',
    ),
  ];

  void _scan() async {
    if (_scanning) return;
    setState(() {
      _scanning = true;
      _found = null;
      _selectedAddress = null;
    });
    // Simule les adresses ACK + le balayage progressif.
    final found = <_I2cDevice>[];
    for (final d in _devices) {
      await Future.delayed(const Duration(milliseconds: 260));
      if (!mounted) return;
      setState(() {
        found.add(d);
      });
    }
    if (!mounted) return;
    setState(() {
      _found = found;
      _scanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const LabHeader(
          title: 'I²C Lab',
          subtitle: 'Inter-Integrated Circuit · SDA + SCL',
          icon: Icons.hub,
          color: AppColors.purple,
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF141B26),
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: CustomPaint(
                  size: const Size(double.infinity, 120),
                  painter: _BusPainter(scanning: _scanning),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _scanning ? null : _scan,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 13,
                  ),
                ),
                icon: _scanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.radar, size: 18),
                label: Text(_scanning ? 'Balayage…' : 'Scanner le bus'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_found == null && !_scanning)
          const AppCard(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.inkSoft, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Le bus I²C n’utilise que 2 lignes : SDA (données) et SCL (horloge). '
                    'Chaque appareil possède une adresse unique sur 7 bits.',
                    style: TextStyle(fontSize: 13, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        if (_found != null) ...[
          const SectionHeader(
            title: 'Périphériques détectés',
            icon: Icons.check,
          ),
          for (final d in _found!)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                onTap: () => setState(() => _selectedAddress = d.address),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10151C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        d.address,
                        style: const TextStyle(
                          color: AppColors.purple,
                          fontFamily: 'MonoTech',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${d.type} · ${d.value}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.inkSoft,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          CodeBlock(
            label: 'i2cdetect -y 1',
            code: '''     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- --
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
20: -- -- -- -- -- -- -- -- -- 29 -- -- -- -- -- --
30: -- -- -- 3c -- -- -- -- -- -- -- -- -- -- -- --
40: -- -- -- -- -- -- -- -- 48 -- -- -- -- -- -- --
50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
60: -- -- -- -- -- -- -- -- 68 -- -- -- -- -- -- --
70: -- -- -- -- -- -- -- --''',
          ),
        ],
        const SizedBox(height: 8),
        if (_selectedAddress != null) _DeviceDetail(address: _selectedAddress!),
        const SizedBox(height: 10),
        const SectionHeader(title: 'Lire un registre', icon: Icons.functions),
        CodeBlock(
          label: 'i2cget / i2cset',
          code: '''
# Lire l’octet d’état du capteur temp à 0x48
i2cget -y 1 0x48 0x00

# Écrire 0x10 dans le registre config de l’OLED
i2cset -y 1 0x3C 0x00 0x10''',
        ),
        const SizedBox(height: 4),
        Callout(
          text:
              'I²C se prononce « I-squared-C » (ou I-two-C). Grâce aux adresses, '
              'on peut connecter des dizaines de capteurs sur seulement 2 fils, '
              'avec résistances pull-up vers 3,3 V.',
          color: AppColors.orange,
          icon: Icons.lightbulb_outline,
          title: 'Astuce',
        ),
      ],
    );
  }
}

class _I2cDevice {
  final String address;
  final String name;
  final String type;
  final String value;
  const _I2cDevice({
    required this.address,
    required this.name,
    required this.type,
    required this.value,
  });
}

class _DeviceDetail extends StatelessWidget {
  final String address;
  const _DeviceDetail({required this.address});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.purple.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.07,
      ),
      borderColor: AppColors.purple.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détail · adresse $address',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
          ),
          const SizedBox(height: 8),
          _row('Mode', 'Controller → périphérique'),
          _row('Fréquence', '100 kHz (standard) / 400 kHz (fast)'),
          _row('Registres', 'Lecture / écriture sur 8 bits'),
          _row('Pull-up', '2 × 4,7 kΩ vers 3,3 V'),
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              k,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(child: Text(v, style: const TextStyle(fontSize: 12.5))),
        ],
      ),
    );
  }
}

class _BusPainter extends CustomPainter {
  final bool scanning;
  _BusPainter({required this.scanning});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    final wire = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFF8A93A3);
    final wireHi = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = scanning ? AppColors.purple : const Color(0xFFB9A2FF);

    // controller à gauche
    final box = Paint()..color = const Color(0xFF232C3B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 22, 76, 76),
        const Radius.circular(8),
      ),
      box,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 22, 76, 76),
        const Radius.circular(8),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = AppColors.purple
        ..strokeWidth = 1.5,
    );
    _text(canvas, 'CTRL', 'SDA/SCL'.split('/')[0], const Offset(20, 50));
    _text(canvas, 'CTRL2', 'SCL', const Offset(20, 70));

    // deux lignes de bus
    canvas.drawLine(
      Offset(72, 42),
      Offset(w - 10, 42),
      scanning ? wireHi : wire,
    );
    canvas.drawLine(
      Offset(72, 76),
      Offset(w - 10, 76),
      scanning ? wireHi : wire,
    );
    _text(canvas, 'SDA', 'SDA', Offset(w - 58, 22));
    _text(canvas, 'SCL', 'SCL', Offset(w - 58, 56));

    // pull-up resistors
    for (final x in [110.0, 170.0]) {
      canvas.drawLine(Offset(x, 42), Offset(x, 76), wire);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, 59), width: 7, height: 8),
        Paint()..color = const Color(0xFF3A4352),
      );
    }
    _text(canvas, 'PU', 'PU', Offset(104, 84));

    // devices à droite avec adresses simulées
    final devs = [('0x3C', 0.15), ('0x48', 0.5), ('0x68', 0.85)];
    final devW = w - 240;
    for (final d in devs) {
      final x = 240 + devW * d.$2;
      canvas.drawCircle(
        Offset(x, 42),
        5,
        Paint()..color = scanning ? AppColors.purple : const Color(0xFF5A6675),
      );
      canvas.drawCircle(
        Offset(x, 76),
        5,
        Paint()..color = scanning ? AppColors.purple : const Color(0xFF5A6675),
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, 104), width: 54, height: 30),
        Paint()..color = const Color(0xFF232C3B),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, 104), width: 52, height: 28),
          const Radius.circular(4),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFF8A93A3)
          ..strokeWidth = 1.2,
      );
      _text(canvas, d.$1, d.$1, Offset(x - 12, 98));
      if (scanning) {
        canvas.drawCircle(
          Offset(x, 42),
          9,
          Paint()..color = AppColors.purple.withValues(alpha: 0.25),
        );
      }
    }
    // balayage: onde
    if (scanning) {
      final wave = Paint()
        ..color = AppColors.purple.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final t = DateTime.now().millisecondsSinceEpoch / 500;
      final path = Path();
      for (var x = 76.0; x < w - 10; x += 3) {
        final y = 42 + math.sin((x + t * 30) / 16) * 8;
        if (x == 76) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, wave);
    }
  }

  void _text(Canvas canvas, String key, String t, Offset p) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: const TextStyle(
          color: Color(0xFFA9B4C4),
          fontSize: 9.5,
          fontFamily: 'MonoTech',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, p);
  }

  @override
  bool shouldRepaint(covariant _BusPainter old) => old.scanning != scanning;
}
