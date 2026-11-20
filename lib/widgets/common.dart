import 'package:flutter/material.dart';

import '../core/constants.dart';
import 'app_card.dart';

/// État vide générique (recherche sans résultat, etc.).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.blue),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// En-tête commun des laboratoires (titre + badge).
class LabHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const LabHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.inkSoft,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Petit jeton coloré.
class Pill extends StatelessWidget {
  final String text;
  final Color color;

  const Pill({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Encart pédagogique (encadré).
class Callout extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  final String title;

  const Callout({
    super.key,
    required this.text,
    required this.color,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      color: color.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.08,
      ),
      borderColor: color.withValues(alpha: 0.45),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(text, style: const TextStyle(fontSize: 13.4, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
