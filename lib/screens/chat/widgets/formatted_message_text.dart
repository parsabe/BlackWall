import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class FormattedMessageText extends StatelessWidget {
  final String text;
  final Color? textColor;
  final double fontSize;

  const FormattedMessageText({
    super.key,
    required this.text,
    this.textColor,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final segments = _parseSegments(text);
    final baseColor = textColor ?? Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < segments.length; i++) ...[
          if (segments[i].isCodeBlock)
            _CodeBlockCard(
              code: segments[i].content,
              language: segments[i].language,
            )
          else if (segments[i].content.trim().isNotEmpty)
            SelectableText.rich(
              _buildInlineSpans(context, segments[i].content, baseColor),
              style: TextStyle(
                fontSize: fontSize,
                color: baseColor,
                height: 1.5,
              ),
            ),
          if (i < segments.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  List<_TextSegment> _parseSegments(String input) {
    final List<_TextSegment> result = [];
    final fenceRegex = RegExp(r'```([a-zA-Z0-9_+-]*)\n?([\s\S]*?)```');
    int lastIndex = 0;

    for (final match in fenceRegex.allMatches(input)) {
      if (match.start > lastIndex) {
        final prose = input.substring(lastIndex, match.start).trim();
        if (prose.isNotEmpty) {
          result.add(_TextSegment(content: prose, isCodeBlock: false));
        }
      }
      final lang = (match.group(1) ?? '').trim();
      final code = (match.group(2) ?? '').trimRight();
      result.add(_TextSegment(
        content: code,
        isCodeBlock: true,
        language: lang.isEmpty ? 'code' : lang,
      ));
      lastIndex = match.end;
    }

    if (lastIndex < input.length) {
      final trailing = input.substring(lastIndex).trim();
      if (trailing.isNotEmpty) {
        result.add(_TextSegment(content: trailing, isCodeBlock: false));
      }
    }

    if (result.isEmpty) {
      result.add(_TextSegment(content: input, isCodeBlock: false));
    }
    return result;
  }

  TextSpan _buildInlineSpans(
      BuildContext context, String input, Color baseColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inlineCodeBg =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF);
    final inlineCodeFg =
        isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8);

    final pattern = RegExp(r'(`[^`]+`|\*\*[^*]+\*\*)');
    final List<InlineSpan> spans = [];
    int lastEnd = 0;

    for (final match in pattern.allMatches(input)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: input.substring(lastEnd, match.start)));
      }
      final token = match.group(0)!;
      if (token.startsWith('`') && token.endsWith('`') && token.length >= 2) {
        final codeText = token.substring(1, token.length - 1);
        spans.add(
          TextSpan(
            text: ' $codeText ',
            style: TextStyle(
              fontFamily: 'SF Mono',
              fontFamilyFallback: AppTheme.monoFontFallback,
              fontSize: fontSize - 1,
              color: inlineCodeFg,
              backgroundColor: inlineCodeBg,
            ),
          ),
        );
      } else if (token.startsWith('**') &&
          token.endsWith('**') &&
          token.length >= 4) {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: baseColor,
            ),
          ),
        );
      }
      lastEnd = match.end;
    }

    if (lastEnd < input.length) {
      spans.add(TextSpan(text: input.substring(lastEnd)));
    }

    return TextSpan(children: spans);
  }
}

class _TextSegment {
  final String content;
  final bool isCodeBlock;
  final String language;

  _TextSegment({
    required this.content,
    required this.isCodeBlock,
    this.language = 'code',
  });
}

class _CodeBlockCard extends StatefulWidget {
  final String code;
  final String language;

  const _CodeBlockCard({required this.code, required this.language});

  @override
  State<_CodeBlockCard> createState() => _CodeBlockCardState();
}

class _CodeBlockCardState extends State<_CodeBlockCard> {
  bool _copied = false;

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF090D16) : const Color(0xFF0F172A);
    final headerBg = isDark ? const Color(0xFF1E293B) : const Color(0xFF1E293B);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: headerBg,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.language.toLowerCase(),
                  style: const TextStyle(
                    fontFamily: 'SF Mono',
                    fontFamilyFallback: AppTheme.monoFontFallback,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                InkWell(
                  onTap: _copyCode,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _copied ? Icons.check : Icons.copy_rounded,
                          size: 13,
                          color: _copied
                              ? AppTheme.safeGreen
                              : const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _copied ? 'Copied' : 'Copy',
                          style: TextStyle(
                            fontSize: 11,
                            color: _copied
                                ? AppTheme.safeGreen
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              widget.code,
              style: const TextStyle(
                fontFamily: 'SF Mono',
                fontFamilyFallback: AppTheme.monoFontFallback,
                fontSize: 13,
                height: 1.45,
                color: Color(0xFFF8FAFC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
