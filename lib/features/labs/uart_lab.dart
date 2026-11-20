import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../widgets/app_card.dart';
import '../../widgets/code_block.dart';
import '../../widgets/common.dart';

/// UART Lab : échange de texte série entre un terminal et une carte.
class UartLab extends StatefulWidget {
  const UartLab({super.key});

  @override
  State<UartLab> createState() => _UartLabState();
}

class _UartLabState extends State<UartLab> {
  final _controller = TextEditingController();
  final List<_UartMessage> _messages = [];
  int _baud = 115200;
  bool _running = false;

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || _running) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _running = true;
      _messages.add(_UartMessage(text, fromHost: true));
    });
    Future.delayed(Duration(milliseconds: _baud <= 9600 ? 1200 : 600), () {
      if (!mounted) return;
      setState(() {
        final reply = _echo(text);
        _messages.add(_UartMessage(reply, fromHost: false));
        _running = false;
      });
    });
  }

  String _echo(String input) {
    final clean = input.replaceAll(RegExp(r'\s+'), ' ');
    return 'Board (UART) : « $clean » reçu · ${clean.length * 8} bits + overhead';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const LabHeader(
          title: 'UART Lab',
          subtitle: 'Simulation terminal série → carte',
          icon: Icons.swap_horiz,
          color: AppColors.blue,
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 0,
            children: [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 9600, label: Text('9600')),
                  ButtonSegment(value: 57600, label: Text('57600')),
                  ButtonSegment(value: 115200, label: Text('115200')),
                ],
                selected: {_baud},
                onSelectionChanged: (s) => setState(() => _baud = s.first),
                showSelectedIcon: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Baud rate : $_baud',
          style: const TextStyle(
            fontFamily: 'MonoTech',
            fontSize: 12,
            color: AppColors.blue,
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.all(14),
          child: _Console(messages: _messages, running: _running),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !_running,
                style: const TextStyle(fontFamily: 'MonoTech', fontSize: 13.5),
                decoration: const InputDecoration(
                  hintText: '> Hello board',
                  prefixIcon: Icon(Icons.keyboard),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: _running ? null : _send,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                backgroundColor: AppColors.blue,
              ),
              icon: const Icon(Icons.send, size: 17),
              label: const Text('Envoyer'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionHeader(
          title: 'Comment ça marche ?',
          icon: Icons.menu_book,
        ),
        Text(
          'UART (Universal Asynchronous Receiver-Transmitter) est un bus série '
          'noyau de l’embarqué : deux fils TX (émission) et RX (réception) reliés en '
          'croisé, plus une masse commune GND. Les deux côtés doivent être réglés sur '
          'le même débit (baud rate). Chaque octet est envoyé bit par bit : '
          'start bit, data, stop bit.',
          style: const TextStyle(fontSize: 13.5, height: 1.5),
        ),
        const SizedBox(height: 12),
        CodeBlock(
          label: 'Câblage correct',
          code: '''
Carte A (TX) ──── (RX) Carte B
Carte A (RX) ──── (TX) Carte B
Carte A (GND) ──── (GND) Carte B''',
        ),
        const SizedBox(height: 6),
        Callout(
          text:
              'Sur Raspberry Pi : /dev/serial0 et minicom -D /dev/serial0 -b 115200',
          color: AppColors.orange,
          icon: Icons.info_outline,
          title: 'En vrai matériel',
        ),
      ],
    );
  }
}

class _UartMessage {
  final String text;
  final bool fromHost;
  _UartMessage(this.text, {required this.fromHost});
}

class _Console extends StatelessWidget {
  final List<_UartMessage> messages;
  final bool running;
  const _Console({required this.messages, required this.running});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: const Color(0xFF161C24),
            child: const Text(
              'CONSOLE SÉRIE · /dev/ttyUSB0',
              style: TextStyle(
                color: AppColors.blue,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length + (running ? 0 : 0),
              itemBuilder: (context, i) => _messageLine(messages[i]),
            ),
          ),
          if (running)
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.blue.withValues(alpha: 0.08),
              child: Row(
                children: const [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.blue,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Transmission en cours…',
                    style: TextStyle(
                      fontFamily: 'MonoTech',
                      fontSize: 11,
                      color: AppColors.blue,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _messageLine(_UartMessage m) {
    final color = m.fromHost ? AppColors.green : AppColors.blue;
    final prefix = m.fromHost ? 'HOST ›' : 'BOARD ›';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        '$prefix ${m.text}',
        style: TextStyle(
          fontFamily: 'MonoTech',
          color: color,
          fontSize: 12.5,
          height: 1.4,
        ),
      ),
    );
  }
}
