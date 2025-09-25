import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';

Future<void> launchUrlFunction({required String url}) async {
  try {
    // Ensure the URL includes the protocol
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    Uri parsedUrl = Uri.parse(url);
    if (await canLaunchUrl(parsedUrl)) {
      await launchUrl(parsedUrl);
    } else {
      throw Exception("Could not launch $url");
    }
  } catch (e) {
    print("Error launching URL: $e");
  }
}

// Underlines any text passed in, ensuring the underline matches the width of the text
class UnderlinedText extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final Color underlineColor; // same as underlineColor
  final Color? hoverTextColor; // optional hover text color
  final VoidCallback? onTap;

  const UnderlinedText({
    super.key,
    required this.text,
    required this.textStyle,
    required this.underlineColor,
    this.hoverTextColor,
    this.onTap,
  });

  @override
  _UnderlinedTextState createState() => _UnderlinedTextState();
}

class _UnderlinedTextState extends State<UnderlinedText> {
  bool _hovering = false;
  late final double _textWidth;
  late final double _textHeight;

  @override
  void initState() {
    super.initState();
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.textStyle),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
    )..layout();
    _textWidth = painter.size.width;
    _textHeight = painter.size.height;
  }

  @override
  Widget build(BuildContext context) {
    return SelectionContainer.disabled(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _hovering = true),
          onTapUp: (_) => setState(() => _hovering = false),
          onTapCancel: () => setState(() => _hovering = false),
          onLongPressStart: (_) => setState(() => _hovering = true),
          onLongPressEnd: (_) => setState(() => _hovering = false),
          onLongPress: () {},
          // this dummy handler eats the long-press and move so a parent Scrollable doesn't - which throws an error
          onTertiaryLongPressMoveUpdate: (_) {},
          onTap: widget.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1) highlight behind text only
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: _textWidth + (_hovering ? 10 : 0),
                height: _textHeight,
                alignment: Alignment.center,
                color: _hovering ? widget.underlineColor : Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: _hovering ? 5 : 0),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: (widget.textStyle ?? const TextStyle()).copyWith(
                    color: _hovering
                        ? (widget.hoverTextColor ?? Colors.white)
                        : widget.textStyle?.color,
                  ),
                  child: Text(widget.text),
                ),
              ),

              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: _hovering ? 0 : 4,
              ),

              // 2) always‐on underline
              Container(
                width: _textWidth,
                height: 2,
                color: _hovering ? Colors.transparent : widget.underlineColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
