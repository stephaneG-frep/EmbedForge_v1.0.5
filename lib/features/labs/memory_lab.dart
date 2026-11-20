import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../widgets/app_card.dart';
import '../../widgets/code_block.dart';
import '../../widgets/common.dart';

/// Memory Lab : simulation de la pile (stack) et du tas (heap).
class MemoryLab extends StatefulWidget {
  const MemoryLab({super.key});

  @override
  State<MemoryLab> createState() => _MemoryLabState();
}

class _MemoryLabState extends State<MemoryLab> {
  static const _stackBase = 16 * 1024;
  int _sp = _stackBase;
  final List<int> _heap = [];
  final List<int> _freed = [];

  bool get _isFull => _heap.length * 32 >= 512;

  void _push() {
    if (_sp <= _stackBase - 4) return;
    setState(() => _sp -= 4);
  }

  void _pop() {
    if (_sp >= _stackBase) return;
    setState(() => _sp += 4);
  }

  void _alloc() {
    if (_isFull) return;
    setState(() {
      _heap.insert(0, 0);
    });
  }

  void _free() {
    if (_heap.isEmpty) return;
    setState(() {
      final e = _heap.removeAt(_heap.length - 1);
      _freed.add(e);
      _freed.removeWhere((x) => x != 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const LabHeader(
          title: 'Memory Lab',
          subtitle: 'Mémoire d’un processus Linux',
          icon: Icons.memory,
          color: AppColors.yellow,
        ),
        const SizedBox(height: 14),
        Container(
          height: 270,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: CustomPaint(
            size: const Size(double.infinity, 270),
            painter: _MemLayoutPainter(
              stackUsed: _stackBase - _sp,
              heapUsed: _heap.length,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _push,
                icon: const Icon(Icons.north, size: 15),
                label: const Text('push'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.orange,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pop,
                icon: const Icon(Icons.south, size: 15),
                label: const Text('pop'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.orange,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: _alloc,
                icon: const Icon(Icons.add, size: 15),
                label: const Text('malloc'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: _free,
                icon: const Icon(Icons.remove, size: 15),
                label: const Text('free'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              _stat(
                'Stack pointer (SP)',
                '0x${_sp.toRadixString(16).toUpperCase()}',
              ),
              _stat('Frames empilées', '${(_stackBase - _sp) ~/ 4}'),
              _stat('Blocs heap (× 32 octets)', '${_heap.length * 32} octets'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const SectionHeader(title: 'Règles à retenir', icon: Icons.autorenew),
        _rule(
          'La pile est gérée automatiquement par les fonctions (arguments, variables locales).',
          AppColors.orange,
        ),
        _rule(
          'Le tas est alloué à la main avec malloc() et libéré avec free().',
          AppColors.blue,
        ),
        _rule(
          'Sur un système embarqué, la RAM est le premier facteur de crash : une stack trop '
          'petite déborde, un malloc sans free fuit.',
          AppColors.red,
        ),
        const SizedBox(height: 10),
        CodeBlock(
          label: 'C · vue d’ensemble',
          code: '''
void foo(void) {
    int local = 4;        // sur la STACK (automatique)
    int *p = malloc(32);  // 32 octets dans le HEAP
    *p = 42;
    free(p);              // obligatoire, sinon fuite
}  // « local » disparaît automatiquement''',
        ),
      ],
    );
  }

  Widget _stat(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(k, style: const TextStyle(fontSize: 13))),
          Text(
            v,
            style: const TextStyle(
              fontFamily: 'MonoTech',
              fontSize: 13,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rule(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 9, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13.2, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemLayoutPainter extends CustomPainter {
  final int stackUsed;
  final int heapUsed;
  _MemLayoutPainter({required this.stackUsed, required this.heapUsed});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    const topPad = 6.0;
    const bottomPad = 26.0;
    final total = size.height - topPad - bottomPad;

    void bar(Rect rect, Color color, String label, String sub) {
      canvas.drawRect(rect, Paint()..color = color);
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFF3A4352)
          ..strokeWidth = 1,
      );
      if (rect.height > 30) {
        _text(canvas, label, Offset(rect.left + 10, rect.top + 12), 11);
        _text(canvas, sub, Offset(rect.left + 10, rect.top + 27), 9.5);
      }
    }

    // Regions
    final text = Size(w * 0.40, total * 0.11);
    final data = Size(w * 0.40, total * 0.16);
    final bss = Size(w * 0.40, total * 0.10);
    final heapH = total * 0.30;
    final stackH = total * 0.28;
    final stackTop = topPad + total - stackH;

    bar(
      Rect.fromLTWH(16, topPad, text.width, text.height),
      const Color(0xFF2A3646),
      'TEXT',
      'code du programme',
    );
    bar(
      Rect.fromLTWH(16, topPad + text.height, data.width, data.height),
      const Color(0xFF233A4A),
      'DATA',
      'variables initialisées',
    );
    bar(
      Rect.fromLTWH(
        16,
        topPad + text.height + data.height,
        bss.width,
        bss.height,
      ),
      const Color(0xFF1F3B32),
      'BSS',
      'non initialisées',
    );
    // Heap
    final heapRect = Rect.fromLTWH(
      16,
      topPad + text.height + data.height + bss.height,
      w * 0.40,
      heapH,
    );
    bar(heapRect, const Color(0xFF243B5A), 'HEAP', 'malloc / free');
    // Stack (croît vers le bas)
    final stackUsedFrac = (stackUsed / (_stackBaseTotal)).clamp(0.0, 1.0);
    final stackRect = Rect.fromLTWH(16, stackTop, w * 0.40, stackH);
    bar(stackRect, const Color(0xFF3A3A2A), 'STACK', 'variables locales');
    // zone utilisée de stack
    if (stackUsedFrac > 0.03) {
      final usedRect = Rect.fromLTWH(
        16,
        stackRect.bottom - stackH * stackUsedFrac,
        w * 0.40,
        stackH * stackUsedFrac,
      );
      canvas.drawRect(
        usedRect,
        Paint()..color = AppColors.orange.withValues(alpha: 0.55),
      );
    }
    // heap utilisé
    final heapUsedFrac = (heapUsed / 16).clamp(0.0, 1.0);
    if (heapUsedFrac > 0.03) {
      final usedRect = Rect.fromLTWH(
        16,
        heapRect.bottom - heapH * heapUsedFrac,
        w * 0.40,
        heapH * heapUsedFrac,
      );
      canvas.drawRect(
        usedRect,
        Paint()..color = AppColors.blue.withValues(alpha: 0.5),
      );
    }
    // flèche droite -> adresses
    _text(canvas, 'adresses hautes', Offset(16, 6), 10);
    _text(canvas, 'adresses basses  ', Offset(16, stackTop + stackH + 6), 10);

    // légende
    _text(
      canvas,
      'malloc() pousse le tas vers le haut',
      Offset(w * 0.44 + 6, total * 0.18),
      10.5,
    );
    _text(
      canvas,
      'push() fait décroître le SP (vers le bas)',
      Offset(w * 0.44 + 6, total * 0.5),
      10.5,
    );
  }

  static const int _stackBaseTotal = 16 * 1024;

  void _text(Canvas canvas, String t, Offset p, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(
          color: const Color(0xFFAEB8C6),
          fontSize: size,
          fontFamily: 'MonoTech',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 300);
    tp.paint(canvas, p);
  }

  @override
  bool shouldRepaint(covariant _MemLayoutPainter old) =>
      old.stackUsed != stackUsed || old.heapUsed != heapUsed;
}
