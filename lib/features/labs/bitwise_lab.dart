import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../widgets/app_card.dart';
import '../../widgets/code_block.dart';
import '../../widgets/common.dart';

/// Bitwise Lab : opérations binaires bit à bit avec affichage visuel.
class BitwiseLab extends StatefulWidget {
  const BitwiseLab({super.key});

  @override
  State<BitwiseLab> createState() => _BitwiseLabState();
}

enum _Op { and, or, xor, not, shl, shr }

class _BitwiseLabState extends State<BitwiseLab> {
  int _a = 0x35;
  int _b = 0x0F;
  _Op _op = _Op.and;

  int get _result {
    final bits = 8;
    switch (_op) {
      case _Op.and:
        return _a & _b;
      case _Op.or:
        return _a | _b;
      case _Op.xor:
        return _a ^ _b;
      case _Op.not:
        return (~_a) & ((1 << bits) - 1);
      case _Op.shl:
        return (_a << 1) & ((1 << bits) - 1);
      case _Op.shr:
        return (_a >> 1) & ((1 << bits) - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const LabHeader(
          title: 'Bitwise Lab',
          subtitle: 'Manipulez les bits comme un pro',
          icon: Icons.settings_ethernet,
          color: AppColors.blue,
        ),
        const SizedBox(height: 14),
        _opSelector(),
        const SizedBox(height: 12),
        _register('A', _a, AppColors.blue),
        if (_op != _Op.not && _op != _Op.shl && _op != _Op.shr)
          _register('B', _b, AppColors.purple),
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Icon(Icons.arrow_downward, color: AppColors.inkSoft, size: 22),
        ),
        _register('R', _result, AppColors.green),
        const SizedBox(height: 14),
        _operationExplain(),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            children: [
              Text(
                'Valeur hex / décimale',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                '${NumberTools.toHex(_result)} = $_result',
                style: const TextStyle(
                  fontFamily: 'MonoTech',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const SectionHeader(
          title: 'À quoi ça sert en embarqué ?',
          icon: Icons.developer_board,
        ),
        _use(
          'Masques de bits sur un registre GPIO : mettre le bit 3 à 1 sans toucher aux autres',
        ),
        _use('I²C / SPI : positionner des bits de configuration'),
        _use('Chiffrement, CRC, paquets réseau, tampons mémoire'),
        const SizedBox(height: 8),
        CodeBlock(
          label: 'C · masques',
          code: '''
#define FLAG_ENABLE  (1 << 3)   // 0b00001000

REG = REG | FLAG_ENABLE;   // activer le bit 3
REG = REG & ~FLAG_ENABLE;  // éteindre le bit 3
REG = REG ^ FLAG_ENABLE;   // basculer le bit 3''',
        ),
      ],
    );
  }

  Widget _opSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final op in _Op.values)
          ChoiceChip(
            label: Text(_opLabel(op)),
            selected: _op == op,
            onSelected: (_) => setState(() => _op = op),
          ),
      ],
    );
  }

  Widget _register(String name, int value, Color color) {
    final bin = NumberTools.toBinary(value, bits: 8);
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              name,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              spacing: 3,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: [
                for (var i = 0; i < 8; i++)
                  GestureDetector(
                    onTap: () => setState(() {
                      if (name == 'A') {
                        _a = _a ^ (1 << (7 - i));
                      } else if (name == 'B') {
                        _b = _b ^ (1 << (7 - i));
                      }
                    }),
                    child: Container(
                      width: 24,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bin[i] == '1'
                            ? color.withValues(alpha: 0.3)
                            : Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1B232F)
                            : const Color(0xFFEFF3F8),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: bin[i] == '1'
                              ? color
                              : const Color(0xFF2A3646),
                        ),
                      ),
                      child: Text(
                        bin[i],
                        style: TextStyle(
                          fontFamily: 'MonoTech',
                          fontWeight: FontWeight.w800,
                          color: bin[i] == '1' ? color : AppColors.inkSoft,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _operationExplain() {
    final map = <_Op, (String, IconData)>{
      _Op.and: ('AND : 1 seulement si les deux bits sont 1', Icons.join_full),
      _Op.or: ('OR : 1 si au moins un des deux bits est 1', Icons.join_inner),
      _Op.xor: ('XOR : 1 si les deux bits sont différents', Icons.join_left),
      _Op.not: ('NOT : inverse chaque bit', Icons.flip),
      _Op.shl: (
        'SHL : décale tous les bits vers la gauche (×2)',
        Icons.keyboard_arrow_left,
      ),
      _Op.shr: (
        'SHR : décale tous les bits vers la droite (÷2)',
        Icons.keyboard_arrow_right,
      ),
    };
    final (text, icon) = map[_op]!;
    return Callout(
      text: text,
      color: AppColors.blue,
      icon: icon,
      title: _opLabel(_op),
    );
  }

  String _opLabel(_Op op) {
    switch (op) {
      case _Op.and:
        return 'AND  &';
      case _Op.or:
        return 'OR  |';
      case _Op.xor:
        return 'XOR  ^';
      case _Op.not:
        return 'NOT  ~';
      case _Op.shl:
        return 'SHL  << 1';
      case _Op.shr:
        return 'SHR  >> 1';
    }
  }

  Widget _use(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 15,
            color: AppColors.green,
          ),
          const SizedBox(width: 9),
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
