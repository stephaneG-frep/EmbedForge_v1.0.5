import 'package:flutter/material.dart';

import '../core/constants.dart';

/// Carte générique avec coin arrondi et bordure douce.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;
  final BorderRadius? radius;
  final Color? borderColor;
  final bool flat;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.onTap,
    this.radius,
    this.borderColor,
    this.flat = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final r = radius ?? BorderRadius.circular(kRadius);

    final container = Container(
      padding: flat ? EdgeInsets.zero : padding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: r,
        border: Border.all(
          color:
              borderColor ??
              (dark
                  ? const Color(0xFF2A3646).withValues(alpha: 0.7)
                  : const Color(0xFFE7ECF3)),
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap == null) return container;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: r, child: container),
    );
  }
}

/// En-tête de section répété.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Puce de niveau colorée.
class LevelChip extends StatelessWidget {
  final int level;
  final bool compact;

  const LevelChip({super.key, required this.level, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(level);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.14,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1),
      ),
      child: Text(
        AppLevels.label(level, !compact),
        style: TextStyle(
          color: color,
          fontSize: compact ? 10.5 : 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static Color _levelColor(int level) => levelColor(level);
}

/// Couleur associée à un niveau (1–5), partagée dans toute l'app.
Color levelColor(int level) {
  switch (level) {
    case 1:
      return AppColors.green;
    case 2:
      return AppColors.blue;
    case 3:
      return AppColors.teal;
    case 4:
      return AppColors.purple;
    case 5:
      return AppColors.orange;
    default:
      return AppColors.blue;
  }
}

/// Pastille d'accent colorée avec icône.
class AccentIcon extends StatelessWidget {
  final String icon;
  final String accent;
  final double size;

  const AccentIcon({
    super.key,
    required this.icon,
    required this.accent,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final color = Accents.colorOf(accent);
    return Container(
      width: size * 2,
      height: size * 2,
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.14,
        ),
        borderRadius: BorderRadius.circular(size * 0.7),
      ),
      child: Icon(Accents.iconOf(icon), size: size, color: color),
    );
  }
}
