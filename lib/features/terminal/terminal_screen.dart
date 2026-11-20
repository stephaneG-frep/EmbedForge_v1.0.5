import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants.dart';

/// Terminal Linux simulé : exécute des commandes dans une console virtuelle,
/// sans jamais toucher au système réel du téléphone. Contient aussi un mode
/// « Défi » qui fait deviner la bonne commande à l’utilisateur.
class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _Line {
  final String text;
  final bool isCommand;
  final Color? color;
  _Line(this.text, {this.isCommand = false, this.color});
}

class _TerminalScreenState extends State<TerminalScreen> {
  static const _challenges = <(String, String)>[
    ('Quelle commande affiche les modules kernel chargés ?', 'lsmod'),
    ('Quelle commande renvoie votre répertoire courant ?', 'pwd'),
    ('Quelle commande liste les processus en cours ?', 'ps'),
    (
      'Quelle commande teste la connexion réseau vers une autre machine ?',
      'ping',
    ),
    ('Quelle commande affiche le journal du noyau ?', 'dmesg'),
    ('Quelle commande configure/consulte les interfaces réseau ?', 'ip'),
    ('Quelle commande affiche le contenu d’un fichier ?', 'cat'),
    ('Quelle commande liste les périphériques USB ?', 'lsusb'),
    ('Quelle commande efface la console ?', 'clear'),
    ('Quelle commande affiche les informations du noyau ?', 'uname'),
  ];

  final List<_Line> _lines = [
    _Line('EmbedForge Terminal — environnement 100 % simulé.'),
    _Line('Tapez « help » pour lister les commandes disponibles.'),
    _Line('Aucune commande n’est réellement exécutée sur votre téléphone.'),
  ];
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  String _cwd = '/home/user';
  bool _challenge = false;
  int _challengeIndex = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toggleChallenge() {
    setState(() {
      _challenge = !_challenge;
    });
    _printLine('Mode défi :', color: AppColors.orange);
    if (_challenge) {
      _printLine(
        '« ${_currentChallenge.$1} »  (réponds dans le terminal)',
        color: AppColors.orange,
      );
    }
  }

  (String, String) get _currentChallenge => _challenges[_challengeIndex];

  void _submit(String raw) {
    final line = raw.trim();
    if (line.isEmpty) return;

    if (_challenge) {
      final expected = _challenges[_challengeIndex].$2;
      final ok = line.trim().split(RegExp(r'\s+')).first == expected;
      setState(() {
        _challenge = false;
        _challengeIndex = (_challengeIndex + 1) % _challenges.length;
      });
      _printLine('$_cwd \$ $line', color: Colors.white);
      _printLine(
        ok
            ? '✓ Correct — bravo !'
            : '✗ Incorrect — la réponse attendue était : $expected',
        color: ok ? AppColors.green : AppColors.red,
      );
      _ctrl.clear();
      return;
    }

    setState(() {
      _lines.add(_Line('$_cwd\$ $line', isCommand: true));
      _lines.addAll(_run(line));
      _lines.add(_Line(''));
    });
    _ctrl.clear();
    _scrollToEnd();
  }

  void _printLine(String text, {Color? color}) {
    setState(() => _lines.add(_Line(text, color: color)));
    _scrollToEnd();
  }

  List<_Line> _run(String line) {
    final args = line.split(RegExp(r'\s+'));
    final cmd = args[0];
    switch (cmd) {
      case 'help':
        return _help();
      case 'clear':
        _lines.clear();
        return [_Line('— console effacée —')];
      case 'pwd':
        return [_Line(_cwd)];
      case 'ls':
        return _ls(args);
      case 'cd':
        return _cd(args);
      case 'cat':
        return _cat(args);
      case 'uname':
        return [
          _Line(
            'Linux embedforge-lab 6.1.31-emb01 #1 SMP PREEMPT aarch64 GNU/Linux',
          ),
        ];
      case 'ps':
        return _ps();
      case 'top':
        return _top();
      case 'ip':
        return _ip();
      case 'ping':
        return _ping(args);
      case 'dmesg':
        return _dmesg();
      case 'lsmod':
        return [
          _Line('Module                Size  Used by'),
          _Line('i2c_bcm2835          32768  0'),
          _Line('spi_bcm2835          24576  0'),
          _Line('gpio_wdt             16384  0'),
          _Line('uio_pdrv_genirq      20480  0'),
        ];
      case 'lsusb':
        return [
          _Line(
            'Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub',
          ),
          _Line(
            'Bus 001 Device 002: ID 2e8a:0005 Raspberry Pi Pico (MicroBoot)',
          ),
          _Line('Bus 001 Device 003: ID 0424:9514 Standard Microsystems Corp.'),
        ];
      case 'free':
        return [
          _Line('             total        used        free'),
          _Line('Mem:         512M        214M        298M'),
          _Line('Swap:          0B          0B          0B'),
        ];
      case 'df':
        return [
          _Line('Filesystem      Size  Used Avail Use% Mounted on'),
          _Line('/dev/mmcblk0p2  14G   2.1G  11G  16% /'),
          _Line('/dev/mmcblk0p1 255M    48M  207M  19% /boot'),
        ];
      case 'whoami':
        return [_Line('user')];
      case 'hostname':
        return [_Line('embedforge-lab')];
      case 'date':
        return [_Line(DateTime.now().toString())];
      case 'echo':
        return [_Line(args.skip(1).join(' '))];
      case 'history':
        final commands = [
          for (final l in _lines)
            if (l.isCommand) l.text.split('\$').last.trim(),
        ];
        return [
          for (var i = 0; i < commands.length; i++)
            _Line('${i + 1}  ${commands[i]}'),
        ];
      case 'exit':
        return [_Line('exit — cette console est simulée.')];
      default:
        return [
          _Line('bash: $cmd : commande introuvable'),
          _Line('Tapez « help » pour la liste des commandes simulées.'),
        ];
    }
  }

  List<_Line> _help() {
    const entries = [
      ('pwd', 'affiche le répertoire courant'),
      ('ls [-la]', 'liste les fichiers'),
      ('cd <rép>', 'change de répertoire'),
      ('cat <fichier>', 'affiche le contenu d’un fichier'),
      ('uname', 'informations noyau'),
      ('ps', 'liste des processus'),
      ('top', 'résumé d’activité système'),
      ('ip addr', 'interfaces réseau'),
      ('ping <hote>', 'teste la connectivité'),
      ('dmesg', 'journal du noyau'),
      ('lsmod', 'modules kernel chargés'),
      ('lsusb', 'périphériques USB'),
      ('free', 'utilisation mémoire'),
      ('df', 'espaces de stockage'),
      ('whoami / hostname / date', 'identité et temps'),
      ('echo <texte>', 'affiche du texte'),
      ('history', 'historique de la session'),
      ('clear', 'efface la console'),
    ];
    return [
      _Line('Commandes disponibles :', color: AppColors.blue),
      for (final e in entries) _Line('  ${e.$1.padRight(16)} ${e.$2}'),
      _Line(''),
      _Line(
        'Fichiers simulés : README.txt · boot.log · scripts.sh · /etc/fstab',
      ),
    ];
  }

  final _dirs = {
    '/home/user': ['README.txt', 'projets', 'scripts.sh', 'boot.log'],
    '/home/user/projets': ['led-gpio', 'capteur-i2c'],
    '/etc': ['fstab', 'hostname', 'passwd'],
    '/dev': ['mmcblk0', 'ttyAMA0', 'gpiochip0', 'i2c-1', 'spidev0.0'],
    '/proc': ['cpuinfo', 'meminfo', 'version', 'uptime'],
    '/var/log': ['syslog', 'kernel.log'],
    '/': [
      'bin',
      'boot',
      'dev',
      'etc',
      'home',
      'lib',
      'proc',
      'root',
      'sbin',
      'sys',
      'tmp',
      'usr',
      'var',
    ],
    '/boot': ['boot.img', 'dtbs', 'config.txt', 'overlays'],
  };

  final _files = {
    '/home/user/README.txt':
        'Bienvenue dans EmbedForge !\nCe fichier est simulé en mémoire.',
    '/home/user/boot.log':
        '[OK] bootloader lancé\n[OK] kernel 6.1.31 démarré\n[OK] services prêts',
    '/home/user/scripts.sh': '#!/bin/sh\necho "hello embarqué"',
    'README.txt': 'Contenu simulé. Astuce : essayez aussi « cat scripts.sh ».',
    'boot.log': '[OK] bootloader lancé\n[OK] kernel 6.1.31 démarré',
    'scripts.sh': '#!/bin/sh\necho "hello embarqué"',
    '/etc/fstab': '# <device> <mount> <type> <options> <dump> <pass>',
    '/etc/hostname': 'embedforge-lab',
    '/proc/version': 'Linux version 6.1.31-emb01 (build@ef) #1 SMP PREEMPT',
    '/proc/meminfo': 'MemTotal: 524288 kB\nMemFree: 305200 kB',
  };

  List<_Line> _ls(List<String> args) {
    final long =
        args.contains('-la') || args.contains('-l') || args.contains('-a');
    final entries = _dirs[_cwd] ?? ['(répertoire simulé)'];
    if (long) {
      return [
        for (final e in entries)
          _Line(
            'drwxr-xr-x  1 user user  ${math.Random().nextInt(4096)}  $_today  $e',
          ),
      ];
    }
    return [for (final e in entries) _Line(e)];
  }

  String get _today => DateTime.now().toString().substring(0, 10);

  List<_Line> _cd(List<String> args) {
    if (args.length < 2 || args[1] == '~') {
      _cwd = '/home/user';
      return [];
    }
    var target = args[1];
    if (target == '..') {
      if (_cwd == '/') {
        _cwd = '/';
      } else {
        final parts = _cwd.split('/')..removeLast();
        _cwd = parts.isEmpty ? '/' : parts.join('/');
      }
      return [];
    }
    if (!target.startsWith('/')) target = '$_cwd/$target'.replaceAll('//', '/');
    if (target.endsWith('/')) target = target.substring(0, target.length - 1);
    if (_dirs.containsKey(target) || target == '/') {
      _cwd = target;
      return [];
    }
    return [_Line('cd: $target : Aucun fichier ou dossier de ce type')];
  }

  List<_Line> _cat(List<String> args) {
    if (args.length < 2) return [_Line('cat: argument manquant')];
    final arg = args[1];
    var path = arg;
    if (!path.startsWith('/')) {
      if (_files.containsKey(path)) {
        // nom relatif déjà connu
      } else {
        path = '$_cwd/$path'.replaceAll('//', '/');
      }
    }
    if (_files.containsKey(path)) {
      return [for (final l in _files[path]!.split('\n')) _Line(l)];
    }
    return [_Line('cat: $arg : Aucun fichier de ce type')];
  }

  List<_Line> _ps() {
    return [
      _Line('PID   USER  TIME  COMMAND'),
      _Line('1     root  00:00 init'),
      _Line('128   root  00:01 systemd'),
      _Line('203   root  00:00 mqtt-broker'),
      _Line('305   user  00:09 app-capteur'),
    ];
  }

  List<_Line> _top() {
    return [
      _Line('top - up 20 min  1 user  load: 0.1'),
      _Line('Mem:  512M used 214M   free 298M'),
      _Line('PID  USER PR NI VIRT RES SHR S CPU% MEM% COMMAND'),
      _Line('305  user 20 0 12m 3.1m 1.2m S  1.2  0.6 app-capteur'),
      _Line('128  root 20 0 23m 5.2m 2.4m S  0.2  1.0 systemd'),
    ];
  }

  List<_Line> _ip() {
    return [
      _Line('1: lo: <LOOPBACK,UP> mtu 65536'),
      _Line('    inet 127.0.0.1/8 scope host lo'),
      _Line('2: wlan0: <BROADCAST,MULTICAST,UP> mtu 1500'),
      _Line('    inet 192.168.1.42/24 brd 192.168.1.255'),
    ];
  }

  List<_Line> _ping(List<String> args) {
    final host = args.length > 1 ? args[1] : '192.168.1.1';
    return [
      _Line('PING $host ($host) 56(84) bytes of data.'),
      _Line('64 bytes from $host: icmp_seq=1 ttl=64 time=0.7 ms'),
      _Line('64 bytes from $host: icmp_seq=2 ttl=64 time=0.5 ms'),
      _Line('64 bytes from $host: icmp_seq=3 ttl=64 time=0.6 ms'),
      _Line('--- $host ping statistics ---'),
      _Line('3 packets transmitted, 0 lost, time 2004ms'),
    ];
  }

  List<_Line> _dmesg() {
    return [
      _Line('[    0.000000] Booting Linux on physical CPU 0x0'),
      _Line('[    0.046210] Machine model: EmbedForge Board v1'),
      _Line('[    0.123456] Memory: 512MB available'),
      _Line('[    0.321093] i2c-bcm: bus 1 registered'),
      _Line('[    0.412998] gpio: GPIO17 configured as output'),
    ];
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal Linux'),
        actions: [
          IconButton(
            tooltip: 'Mode défi « trouve la commande »',
            onPressed: _toggleChallenge,
            icon: Icon(
              _challenge ? Icons.flag : Icons.flag_outlined,
              color: _challenge ? AppColors.orange : null,
            ),
          ),
          IconButton(
            tooltip: 'Historique',
            onPressed: () => _submit('history'),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF080C12),
        child: Column(
          children: [
            if (_challenge) _challengeBanner(),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                itemCount: _lines.length,
                itemBuilder: (context, i) {
                  final line = _lines[i];
                  return Text(
                    line.text,
                    style: TextStyle(
                      fontFamily: 'MonoTech',
                      fontSize: 12.5,
                      height: 1.45,
                      color:
                          line.color ??
                          (line.isCommand
                              ? const Color(0xFFE6EDF7)
                              : const Color(0xFFB9C3D0)),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  border: Border(
                    top: BorderSide(color: const Color(0xFF1B232F), width: 1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$_cwd\$',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontFamily: 'MonoTech',
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        style: const TextStyle(
                          fontFamily: 'MonoTech',
                          color: Colors.white,
                          fontSize: 13.5,
                        ),
                        cursorColor: AppColors.green,
                        onSubmitted: _submit,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          hintText: 'taper une commande…',
                          hintStyle: TextStyle(
                            color: Color(0xFF5A6675),
                            fontFamily: 'MonoTech',
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          _submit(_ctrl.text.isNotEmpty ? _ctrl.text : 'help'),
                      icon: const Icon(
                        Icons.play_arrow,
                        color: AppColors.green,
                        size: 22,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _challengeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1408),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag, color: AppColors.orange, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'DÉFI : ${_currentChallenge.$1}',
              style: const TextStyle(
                fontSize: 12.3,
                height: 1.35,
                color: Color(0xFFFFE3C2),
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              _challengeIndex = (_challengeIndex + 1) % _challenges.length;
            }),
            icon: const Icon(Icons.refresh, color: AppColors.orange, size: 18),
            tooltip: 'Nouveau défi',
          ),
        ],
      ),
    );
  }
}
