import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants.dart';

/// Anneau de progression.
class ProgressRing extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final double stroke;
  final Color? color;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 62,
    this.stroke = 6,
    this.color,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0.0, 1.0).toDouble()),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => CustomPaint(
              painter: _RingPainter(
                value: v,
                color: c,
                track: dark ? const Color(0xFF2A3646) : const Color(0xFFE2E8F1),
              ),
            ),
          ),
          if (child != null)
            Center(
              child: Container(padding: EdgeInsets.zero, child: child!),
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color track;

  _RingPainter({required this.value, required this.color, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 3;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final start = -math.pi / 2;
    final paintTrack = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, paintTrack);
    final paintArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, start, math.pi * 2 * value, false, paintArc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color;
}

/// Barre de progression fine avec pourcentage.
class MiniBar extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;

  const MiniBar({super.key, required this.value, this.color, this.height = 7});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0).toDouble(),
        minHeight: height,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A3646)
            : const Color(0xFFE2E8F1),
        valueColor: AlwaysStoppedAnimation(c),
      ),
    );
  }
}

/// Compteur « x / y » affiché à droite d'une barre.
class CountLabel extends StatelessWidget {
  final int current;
  final int total;

  const CountLabel({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$current / $total',
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
    );
  }
}

/// Badge de progression XP.
class XpBadge extends StatelessWidget {
  final int xp;

  const XpBadge({super.key, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.14,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.rocket_launch, size: 13, color: AppColors.purple),
          const SizedBox(width: 5),
          Text(
            '$xp xp',
            style: const TextStyle(
              color: AppColors.purple,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
