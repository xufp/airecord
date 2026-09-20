import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class MathMarkdown extends StatelessWidget {
  final String data;
  final bool selectable;
  final Color? textColor;
  final double? fontSize;

  const MathMarkdown({
    Key? key,
    required this.data,
    this.selectable = false,
    this.textColor,
    this.fontSize,
  }) : super(key: key);

  TextStyle _style() => unifiedTextStyle(color: textColor, fontSize: fontSize);

  @override
  Widget build(BuildContext context) {
    final style = _style();
    return MarkdownBody(
      data: data,
      selectable: true,
      builders: {
        'inlineMath': InlineMathBuilder(color: textColor, fontSize: fontSize),
        'blockMath': BlockMathBuilder(color: textColor, fontSize: fontSize),
        'math': MathBuilder(color: textColor, fontSize: fontSize),
      },
      extensionSet: md.ExtensionSet([
        const md.FencedCodeBlockSyntax(),
      ], [
        MathSyntax(),
      ],),
      styleSheet: MarkdownStyleSheet(
        a: style,
        p: style,
        h1: style,
        h2: style,
        h3: style,
        h4: style,
        h5: style,
        h6: style,
        em: style,
        strong: style,
        blockquote: style,
        code: style,
        listBullet: style,
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        tableBody: style,
        tableHead: style,
      ),
    );
  }
}

TextStyle unifiedTextStyle({Color? color, double? fontSize}) {
  return TextStyle(
      fontSize: fontSize ?? 12.0,
      color: color ?? Colors.white);
}

class MathBuilder extends MarkdownElementBuilder {
  final Color? color;
  final double? fontSize;

  MathBuilder({this.color, this.fontSize});

  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    return Text(
      text.text,
      style: preferredStyle ??
          unifiedTextStyle(color: color, fontSize: fontSize),
    );
  }
}

class MathSyntax extends md.InlineSyntax {
  MathSyntax() : super(r'\$([^$]*)\$');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('math', match[1] ?? ''));
    return true;
  }
}

/// 渲染行内数学公式（退回纯文本显示）
class InlineMathBuilder extends MarkdownElementBuilder {
  final Color? color;
  final double? fontSize;

  InlineMathBuilder({this.color, this.fontSize});

  @override
  Widget? visitText(text, style) {
    style = TextStyle(
      color: color ?? Colors.white,
      fontSize: fontSize,
    );
    final content = text.text;
    if (content.startsWith(r'$') && content.endsWith(r'$')) {
      final mathContent = content.substring(1, content.length - 1);
      return Text(mathContent, style: style);
    }
    return Text(content, style: style);
  }
}

/// 渲染块级数学公式（退回纯文本显示）
class BlockMathBuilder extends MarkdownElementBuilder {
  final Color? color;
  final double? fontSize;

  BlockMathBuilder({this.color, this.fontSize});

  @override
  Widget? visitText(text, style) {
    style = TextStyle(
      color: color ?? Colors.white,
      fontSize: fontSize,
    );
    final content = text.text;
    if (content.startsWith(r'$$') && content.endsWith(r'$$')) {
      final mathContent = content.substring(2, content.length - 2);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(mathContent, style: style),
      );
    }
    return Text(content, style: style);
  }
}
