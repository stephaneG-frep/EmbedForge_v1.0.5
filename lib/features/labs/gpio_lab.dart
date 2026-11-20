import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../widgets/app_card.dart';
import '../../widgets/code_block.dart';
import '../../widgets/common.dart';

/// GPIO Lab : carte virtuelle avec pin, résistance et LED.
class GpioLab extends StatefulWidget {
  const GpioLab({super.key});

  @override
  State<GpioLab> createState() => _GpioLabState();
}

class _GpioLabState extends State<GpioLab> {
  bool _high = false;
  int _selectedPin = 17;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const LabHeader(
          title: 'GPIO Lab',
          subtitle: 'Commande une LED via une broche',
          icon: Icons.bolt,
          color: AppColors.green,
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            children: [
              SizedBox(height: 34),
              _Board(
                high: _high,
                pinLabel: 'GPIO$_selectedPin',
                onPinTap: () => setState(() => _high = !_high),
              ),
              const SizedBox(height: 20),
              _LedVisual(high: _high),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                children: [
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 17, label: Text('GPIO17')),
                      ButtonSegment(value: 22, label: Text('GPIO22')),
                      ButtonSegment(value: 23, label: Text('GPIO23')),
                    ],
                    selected: {_selectedPin},
                    onSelectionChanged: (s) =>
                        setState(() => _selectedPin = s.first),
                    showSelectedIcon: false,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _high = false),
                      icon: const Icon(Icons.arrow_downward, size: 16),
                      label: const Text('GPIO LOW'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => setState(() => _high = true),
                      icon: const Icon(Icons.arrow_upward, size: 16),
                      label: const Text('GPIO HIGH'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: const Color(0xFF06250F),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Principe', icon: Icons.menu_book),
        Text(
          'Une broche GPIO peut être configurée en sortie : elle fournit alors '
          '2 niveaux logiques. HIGH = tension ≈ 3,3 V : la LED s’allume via la '
          'résistance de limitation (≈ 330 Ω) qui protège la LED du courant '
          'excessif. LOW = 0 V : la LED s’éteint.',
          style: const TextStyle(fontSize: 13.5, height: 1.5),
        ),
        const SizedBox(height: 12),
        CodeBlock(
          label: 'exemple Python (Raspberry Pi)',
          code: '''
Câblage :
  3V3 ── GPIO17 ── 330 Ω ── LED ── GND

import RPi.GPIO as GPIO
GPIO.setmode(GPIO.BCM)
GPIO.setup(17, GPIO.OUT)

GPIO.output(17, GPIO.HIGH)   # LED allumée
GPIO.output(17, GPIO.LOW)    # LED éteinte''',
        ),
        const SizedBox(height: 6),
        Callout(
          text:
              'Lorsque la broche est en HIGH, c’est la borne + de la LED qui voit '
              '3,3 V et la borne - qui voit 0 V. Le courant traversant la résistance '
              'est alors I = U / R = 3,3 / 330 ≈ 10 mA, une valeur sûre pour une LED standard.',
          color: AppColors.orange,
          icon: Icons.warning_amber_rounded,
          title: 'Ne pas oublier la résistance',
        ),
      ],
    );
  }
}

class _Board extends StatelessWidget {
  final bool high;
  final String pinLabel;
  final VoidCallback onPinTap;

  const _Board({
    required this.high,
    required this.pinLabel,
    required this.onPinTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF123016),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A5C33), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            'CARTE VIRTUELLE',
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
              color: dark ? const Color(0xFF7BC38A) : const Color(0xFF0D3B16),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: CustomPaint(
              size: const Size(double.infinity, 150),
              painter: _BoardPainter(high: high, pinLabel: pinLabel),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PinDot(label: '3V3', active: false),
              const SizedBox(width: 12),
              _PinDot(label: pinLabel, active: high),
              const SizedBox(width: 12),
              _PinDot(label: 'GND', active: false),
            ],
          ),
        ],
      ),
    );
  }
}

class _PinDot extends StatelessWidget {
  final String label;
  final bool active;
  const _PinDot({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: active ? AppColors.green : const Color(0xFF39423C),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9.5,
            fontFamily: 'MonoTech',
          ),
        ),
      ],
    );
  }
}

class _BoardPainter extends CustomPainter {
  final bool high;
  final String pinLabel;

  _BoardPainter({required this.high, required this.pinLabel});

  @override
  void paint(Canvas canvas, Size size) {
    const traceColor = Color(0xFF7BC38A);
    const traceColorHi = AppColors.green;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = traceColor;

    // Trame de fond façon circuit imprimé.
    final grid = Paint()
      ..color = const Color(0xFF1E4726)
      ..strokeWidth = 1;
    for (var x = 20.0; x < size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 18.0; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final hiPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = high ? traceColorHi : traceColor;

    // Piste : pin -> résistance -> LED.
    final pinsY = size.height - 52;
    // Pin (vert si haut)
    canvas.drawCircle(
      Offset(30, pinsY),
      9,
      Paint()..color = high ? traceColorHi : const Color(0xFF39423C),
    );
    // trace horizontale
    canvas.drawLine(
      Offset(30, pinsY),
      Offset(70, pinsY),
      high ? hiPaint : paint,
    );
    // résistance (zigzag)
    final rTop = Offset(80, pinsY - 6);
    final z = _zigzag(canvas, rTop, 26, paint);
    // trace vers LED
    canvas.drawLine(z, Offset(150, pinsY), high ? hiPaint : paint);
    // anode LED (triangle)
    _tri(canvas, Offset(150, pinsY));
    // trace vers GND
    canvas.drawLine(
      Offset(196, pinsY),
      Offset(246, pinsY - 18),
      high ? hiPaint : paint,
    );
    canvas.drawCircle(
      Offset(246, pinsY - 18),
      3,
      Paint()..color = const Color(0xFF39423C),
    );

    // Label résistance
    _text(canvas, '330 Ω', Offset(62, pinsY - 24));
    _text(canvas, 'LED', Offset(168, pinsY - 24));
    // Signal GPIO
    if (high) {
      final glow = Paint()..color = AppColors.green.withValues(alpha: 0.25);
      canvas.drawCircle(Offset(30, pinsY), 13, glow);
    }
  }

  void _text(Canvas canvas, String t, Offset p) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: const TextStyle(
          color: Color(0xFF9BD6A8),
          fontSize: 8.5,
          fontFamily: 'MonoTech',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, p);
  }

  void _tri(Canvas canvas, Offset p) {
    final paint = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.fill;
    final pts = [p, p.translate(0, 20), p.translate(18, 10)];
    final path = Path()
      ..moveTo(pts[0].dx, pts[0].dy)
      ..lineTo(pts[1].dx, pts[1].dy)
      ..lineTo(pts[2].dx, pts[2].dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  Offset _zigzag(Canvas canvas, Offset start, double width, Paint paint) {
    var x = start.dx;
    var y = start.dy;
    canvas.drawLine(start, Offset(start.dx + 4, start.dy), paint);
    final step = 6.0;
    while (x < start.dx + width) {
      x += step;
      y = start.dy - (y == start.dy ? step : -step);
      canvas.drawLine(Offset(x, y), Offset(x + step, start.dy), paint);
      x += step;
      canvas.drawLine(Offset(x, start.dy), Offset(x + step, start.dy), paint);
      x += step;
    }
    return Offset(x, start.dy);
  }

  @override
  bool shouldRepaint(covariant _BoardPainter old) =>
      old.high != high || old.pinLabel != pinLabel;
}

class _LedVisual extends StatelessWidget {
  final bool high;
  const _LedVisual({required this.high});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 88,
      decoration: BoxDecoration(
        color: high
            ? AppColors.green.withValues(alpha: 0.22)
            : const Color(0xFF11161C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: high ? AppColors.green : const Color(0xFF2A3646),
          width: 1.4,
        ),
      ),
      child: Center(
        child: AnimatedScale(
          scale: high ? 1.05 : 1,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: high ? AppColors.green : const Color(0xFF2A3038),
              boxShadow: high
                  ? [
                      BoxShadow(
                        color: AppColors.green.withValues(alpha: 0.7),
                        blurRadius: 26,
                        spreadRadius: 6,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: high ? const Color(0xFF06250F) : const Color(0xFF5A6675),
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
