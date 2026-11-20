import 'package:flutter/material.dart';

/// Palette et constantes globales d'EmbedForge.
class AppColors {
  AppColors._();

  static const anthracite = Color(0xFF10151C);
  static const anthraciteLight = Color(0xFF171E28);
  static const surfaceDark = Color(0xFF1B232F);
  static const cardDark = Color(0xFF202A38);
  static const blue = Color(0xFF38B6FF); // bleu électronique
  static const blueDeep = Color(0xFF1E6EA8);
  static const green = Color(0xFF40E583); // vert terminal
  static const greenDeep = Color(0xFF1FA35C);
  static const offWhite = Color(0xFFF2F5F9);
  static const orange = Color(0xFFFFA94D);
  static const red = Color(0xFFFF6B6B);
  static const purple = Color(0xFFB388FF);
  static const teal = Color(0xFF4DD0E1);
  static const pink = Color(0xFFFF7EB6);
  static const yellow = Color(0xFFFFD94D);

  // Surfaces light
  static const surfaceLight = Color(0xFFF6F8FB);
  static const cardLight = Color(0xFFFFFFFF);
  static const inkLight = Color(0xFF20262E);
  static const inkSoft = Color(0xFF5A6675);
}

/// Niveaux de progression utilisés dans toute l'application.
class AppLevels {
  AppLevels._();

  static const int fundamentals = 1;
  static const int system = 2;
  static const int hardware = 3;
  static const int platform = 4;
  static const int pro = 5;

  static String label(int level, bool long) {
    switch (level) {
      case fundamentals:
        return long ? 'Niveau 1 · Fondamentaux' : 'Fondamentaux';
      case system:
        return long ? 'Niveau 2 · Système & Outils' : 'Système & Outils';
      case hardware:
        return long ? 'Niveau 3 · Matériel & Bus' : 'Matériel & Bus';
      case platform:
        return long ? 'Niveau 4 · Plateforme Linux' : 'Plateforme Linux';
      case pro:
        return long ? 'Niveau 5 · Pro & Production' : 'Pro & Production';
      default:
        return 'Niveau $level';
    }
  }
}

/// Noms d'accents utilisés dans le JSON -> couleurs.
class Accents {
  Accents._();

  static const blue = 'blue';
  static const green = 'green';
  static const orange = 'orange';
  static const purple = 'purple';
  static const teal = 'teal';
  static const red = 'red';
  static const pink = 'pink';
  static const yellow = 'yellow';

  static Color colorOf(String name) {
    switch (name) {
      case green:
        return AppColors.green;
      case orange:
        return AppColors.orange;
      case purple:
        return AppColors.purple;
      case teal:
        return AppColors.teal;
      case red:
        return AppColors.red;
      case pink:
        return AppColors.pink;
      case yellow:
        return AppColors.yellow;
      case blue:
      default:
        return AppColors.blue;
    }
  }

  static IconData iconOf(String name) {
    switch (name) {
      case 'terminal':
        return Icons.terminal;
      case 'memory':
        return Icons.memory;
      case 'chip':
        return Icons.memory_rounded;
      case 'code':
        return Icons.code;
      case 'codelab':
        return Icons.code_rounded;
      case 'bolt':
        return Icons.bolt;
      case 'electric':
        return Icons.electric_bolt;
      case 'network':
        return Icons.lan;
      case 'router':
        return Icons.router;
      case 'cpu':
        return Icons.memory_rounded;
      case 'usb':
        return Icons.usb;
      case 'storage':
        return Icons.storage;
      case 'shield':
        return Icons.shield;
      case 'security':
        return Icons.security;
      case 'speed':
        return Icons.speed;
      case 'timer':
        return Icons.timer;
      case 'microchip':
        return Icons.developer_board;
      case 'board':
        return Icons.developer_board;
      case 'linux':
        return Icons.adb;
      case 'git':
        return Icons.account_tree;
      case 'kernel':
        return Icons.settings_suggest;
      case 'wrench':
        return Icons.build;
      case 'bug':
        return Icons.bug_report;
      case 'inventory':
        return Icons.inventory_2;
      case 'layers':
        return Icons.layers;
      case 'hub':
        return Icons.hub;
      case 'book':
        return Icons.auto_stories;
      case 'check':
        return Icons.check_circle;
      case 'star':
        return Icons.star;
      case 'flag':
        return Icons.flag;
      case 'rocket':
        return Icons.rocket_launch;
      case 'database':
        return Icons.storage;
      case 'link':
        return Icons.link;
      case 'details':
        return Icons.info_outline;
      case 'tools':
        return Icons.handyman;
      case 'home':
        return Icons.home_work;
      case 'wifi':
        return Icons.wifi;
      case 'sd':
        return Icons.sd_card;
      case 'fingerprint':
        return Icons.fingerprint;
      default:
        return Icons.memory;
    }
  }
}

/// Durée de l'animation de la barre de copie.
const kSnackDuration = Duration(milliseconds: 1400);

const double kRadius = 18.0;
const double kRadiusSmall = 12.0;
