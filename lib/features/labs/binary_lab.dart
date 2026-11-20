import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../widgets/app_card.dart';
import '../../widgets/common.dart';

/// Binary Lab : conversion interactive décimal / binaire / hexadécimal.
class BinaryLab extends StatefulWidget {
  const BinaryLab({super.key});

  @override
  State<BinaryLab> createState() => _BinaryLabState();
}

class _BinaryLabState extends State<BinaryLab> {
  int _value = 255;
  bool _hexMode = false;
  bool _decMode = false;

  @override
  Widget build(BuildContext context) {
    final bin = NumberTools.toBinary(_value, bits: 16);
    final displayedBits = 16;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const LabHeader(
          title: 'Binary Lab',
          subtitle: 'Décimal · Binaire · Hexadécimal',
          icon: Icons.tag,
          color: AppColors.pink,
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            children: [
              _ValueCard(
                label: 'Décimal',
                value: '$_value',
                color: AppColors.blue,
                mode: _decMode,
              ),
              const SizedBox(height: 10),
              _ValueCard(
                label: 'Binaire',
                value: bin,
                color: AppColors.green,
                mode: !_decMode && !_hexMode,
              ),
              const SizedBox(height: 10),
              _ValueCard(
                label: 'Hexadécimal',
                value: NumberTools.toHex(_value, digits: displayedBits ~/ 4),
                color: AppColors.pink,
                mode: _hexMode,
              ),
              const SizedBox(height: 14),
              Text(
                'Bits (MSB → LSB)',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.inkSoft.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              _bitRow(bin, displayedBits),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _value.toDouble(),
                      max: 65535,
                      divisions: 65535,
                      activeColor: AppColors.pink,
                      onChanged: (v) => setState(() => _value = v.round()),
                    ),
                  ),
                  SizedBox(
                    width: 92,
                    child: Text(
                      '0 ≤ n ≤ 65535',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.inkSoft.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Déc → Bin')),
                  ButtonSegment(value: true, label: Text('Hex → Bin')),
                ],
                selected: {_hexMode},
                onSelectionChanged: (s) => setState(() {
                  _hexMode = s.first;
                  _decMode = !s.first;
                }),
                showSelectedIcon: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(
          title: 'Comment convertir ?',
          icon: Icons.menu_book,
        ),
        Text(
          'Le binaire (base 2) n’utilise que 0 et 1. Chaque position vaut une '
          'puissance de 2 : 128, 64, 32, 16, 8, 4, 2, 1… L’hexadécimal (base 16) '
          'regroupe 4 bits dans un chiffre : 0000=0 … 1010=A, 1111=F. '
          'Ainsi 0xFF = 255 = 11111111.',
          style: const TextStyle(fontSize: 13.5, height: 1.5),
        ),
        const SizedBox(height: 10),
        _table(context),
        const SizedBox(height: 6),
        Text(
          'Faites glisser le curseur : la valeur change instantanément, les trois '
          'représentations restent synchronisées.',
          style: const TextStyle(
            fontSize: 12.5,
            fontStyle: FontStyle.italic,
            color: AppColors.inkSoft,
          ),
        ),
      ],
    );
  }

  Widget _bitRow(String bin, int bits) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < bits; i++)
            Container(
              width: 26,
              height: 30,
              alignment: Alignment.center,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: bin[i] == '1'
                    ? AppColors.green.withValues(alpha: 0.25)
                    : Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1B232F)
                    : const Color(0xFFEFF3F8),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: bin[i] == '1'
                      ? AppColors.green
                      : const Color(0xFF2A3646),
                  width: 1,
                ),
              ),
              child: Text(
                bin[i],
                style: TextStyle(
                  fontFamily: 'MonoTech',
                  fontWeight: FontWeight.w800,
                  color: bin[i] == '1' ? AppColors.green : AppColors.inkSoft,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _table(BuildContext context) {
    const rows = [
      ['Déc', '0', '1', '2', '3', '9', '10', '15', '31', '255'],
      [
        'Bin',
        '0',
        '1',
        '10',
        '11',
        '1001',
        '1010',
        '1111',
        '11111',
        '11111111',
      ],
      ['Hex', '0x0', '0x1', '0x2', '0x3', '0x9', '0xA', '0xF', '0x1F', '0xFF'],
    ];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3646)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(color: const Color(0xFF2A3646), width: 0.6),
        children: [
          for (final row in rows)
            TableRow(
              children: [
                for (final cell in row)
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      cell,
                      style: TextStyle(
                        fontFamily: row[0] == 'Bin'
                            ? 'MonoTech'
                            : (row[0] == 'Hex' ? 'MonoTech' : 'Static'),
                        fontSize: 12,
                        fontWeight: row[0] == cell
                            ? FontWeight.w800
                            : FontWeight.w400,
                        color: row[0] == cell ? AppColors.blue : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool mode;
  const _ValueCard({
    required this.label,
    required this.value,
    required this.color,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: mode ? 0.14 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: mode ? 0.8 : 0.3)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const Spacer(),
          SelectableText(
            value,
            style: TextStyle(
              fontFamily: 'MonoTech',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
