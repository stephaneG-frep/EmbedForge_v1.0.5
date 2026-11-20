import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';
import '../core/constants.dart';

/// Bloc de code lisible avec bouton de copie.
class CodeBlock extends StatefulWidget {
  final String code;
  final String? label;
  final bool expandOnTap;
  final double fontSize;
  final EdgeInsets padding;

  const CodeBlock({
    super.key,
    required this.code,
    this.label,
    this.expandOnTap = false,
    this.fontSize = 13.5,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _copied = false;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).extension<AppSurfaceStyle>()!;
    final mono = AppTheme.codeFont;
    final content = widget.code.trimRight();

    final maxLines = widget.expandOnTap && content.split('\n').length > 12
        ? (_expanded ? null : 12)
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: style.codeBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF263241), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.label != null || widget.expandOnTap)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              color: const Color(0xFF0A0E13),
              child: Row(
                children: [
                  if (widget.label != null)
                    Expanded(
                      child: Text(
                        widget.label!,
                        style: TextStyle(
                          color: AppColors.blue,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          fontFamily: mono,
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: _copy,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _copied ? Icons.check : Icons.copy,
                            size: 14,
                            color: _copied
                                ? AppColors.green
                                : AppColors.offWhite.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _copied ? 'Copié' : 'Copier',
                            style: TextStyle(
                              color: _copied
                                  ? AppColors.green
                                  : AppColors.offWhite.withValues(alpha: 0.8),
                              fontSize: 11.5,
                              fontFamily: mono,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          InkWell(
            onTap: widget.expandOnTap
                ? () => setState(() => _expanded = !_expanded)
                : null,
            child: Container(
              width: double.infinity,
              padding: widget.padding,
              child: SelectableText(
                content,
                maxLines: maxLines,
                style: TextStyle(
                  color: _tintLine(content),
                  fontFamily: mono,
                  fontSize: widget.fontSize,
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _tintLine(String code) {
    if (code.startsWith('\$ ')) return AppColors.green;
    return const Color(0xFFE2E8F2);
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code.trim()));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(kSnackDuration);
    if (mounted) setState(() => _copied = false);
  }
}
