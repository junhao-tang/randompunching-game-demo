import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:targetmechanism/types.dart';

class DisplayComponent extends TextComponent {
  final Map<TeamKey, int> headcount;

  DisplayComponent({required this.headcount}) {
    anchor = Anchor.topLeft;
    const style = TextStyle(
      color: Colors.black,
      fontSize: 15,
    );
    textRenderer = TextPaint(style: style);
  }

  @override
  void update(double dt) {
    super.update(dt);
    text = """
Headcount:
${headcount.entries.map((e) => "${e.key}: ${e.value}").join("\n")}
""";
  }
}
