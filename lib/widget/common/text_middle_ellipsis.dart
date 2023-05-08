import 'package:flutter/material.dart';

class TextMiddleEllipsis extends StatelessWidget {
  final String data;
  final TextStyle style;
  final TextAlign? textAlign;
  const TextMiddleEllipsis(
    this.data, {
    Key? key,
    this.textAlign,
    this.style = const TextStyle(),
  }) : super(key: key);

  final textDirection = TextDirection.ltr;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        if (constraint.maxWidth <= _textSize(data, style).width &&
            data.length > 10) {
          var endPart = data.trim().substring(data.length - 10);
          return Row(
            children: [
              Expanded(
                child: Text(
                  data,
                  style: style,
                  textAlign: textAlign,
                  overflow: TextOverflow.ellipsis,
                  textDirection: textDirection,
                ),
              ),
              Text(
                endPart,
                style: style,
                textDirection: textDirection,
                textAlign: textAlign,
              ),
            ],
          );
        }
        return Text(
          data,
          style: style,
          textAlign: textAlign,
          maxLines: 1,
          textDirection: textDirection,
        );
      },
    );
  }

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style:
            TextStyle.lerp(const TextStyle(fontFamily: "Pretendard"), style, 0),
      ),
      maxLines: 1,
      textDirection: textDirection,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}
