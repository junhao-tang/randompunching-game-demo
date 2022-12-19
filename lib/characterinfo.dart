import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:targetmechanism/character.dart';
import 'package:targetmechanism/types.dart';

class CharacterInfoComponent extends TextComponent {
  final CharacterComponent data;

  CharacterInfoComponent({required this.data}) {
    anchor = Anchor.topLeft;
    final style = TextStyle(
      color: data.teamKey == TeamKey.team1
          ? const Color.fromARGB(255, 0, 0, 0)
          : const Color.fromARGB(255, 255, 255, 255),
      fontSize: 15,
    );
    textRenderer = TextPaint(style: style);
  }

  @override
  void update(double dt) {
    super.update(dt);
    text = """
TeamKey: ${data.teamKey}
Hp: ${data.hp}/${data.stats.maxHp}
Status: ${data.status}
Target: ${data.target?.id}
Destination: ${data.destination}
""";
  }
}
