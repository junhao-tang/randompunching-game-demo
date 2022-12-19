import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:targetmechanism/character.dart';
import 'package:targetmechanism/display.dart';
import 'package:targetmechanism/types.dart';
import 'package:uuid/uuid.dart';

class DummyGame extends FlameGame with SingleGameInstance {
  static const Uuid uuid = Uuid();
  static const playerPerTeam = 2;
  // static const frameSize = Size(187, 187);
  static const frameSize = Size(644, 608);
  static const String assetPath = "human.png";
  static const Map<CharacterStatus, AnimationData> animationsData = {
    CharacterStatus.idle: AnimationData(
      amount: 2,
      stepTime: 0.5,
      frameSize: frameSize,
      framePosition: Offset(0, 1),
      loop: true,
    ),
    CharacterStatus.move: AnimationData(
      amount: 4,
      stepTime: 0.5,
      frameSize: frameSize,
      framePosition: Offset(0, 0),
      loop: true,
    ),
    CharacterStatus.attackmove: AnimationData(
      amount: 4,
      stepTime: 0.5,
      frameSize: frameSize,
      framePosition: Offset(0, 0),
      loop: true,
    ),
  };
  static const attackAnimationData = AttackAnimationData(
    amount: 3,
    frameSize: frameSize,
    framePosition: Offset(0, 2),
    loop: true,
  );
  static const deathAnimationData = AnimationData(
    amount: 1,
    stepTime: 1,
    frameSize: frameSize,
    framePosition: Offset(0, 0),
    loop: false,
  );
  static const CharacterStats stats = CharacterStats(
    maxHp: 80,
    attack: 7,
    movementSpeed: 2,
    attackRange: 75,
    assetPath: assetPath,
    animationsData: animationsData,
    deathAnimationData: deathAnimationData,
    attackAnimationData: attackAnimationData,
    attackSpeed: 0.25,
  );

  final Random _rand = Random();

  Map<TeamKey, Map<String, CharacterComponent>> characters =
      Map.fromIterable(TeamKey.values, value: (element) => {});
  final Map<TeamKey, int> headcount = {};

  void spawnCharacter(TeamKey teamKey) {
    final character = CharacterComponent(
      position: randomPosition,
      stats: stats,
      teamKey: teamKey,
      id: uuid.v4(),
    );
    characters[character.teamKey]![character.id] = character;
    add(character);
  }

  void removeCharacter(CharacterComponent character) {
    characters[character.teamKey]!.remove(character.id);
    remove(character);
    spawnCharacter(character.teamKey);
  }

  @override
  Color backgroundColor() => Colors.white;

  void announceKill(CharacterComponent killer, CharacterComponent victim) {
    headcount[killer.teamKey] ??= 0;
    headcount[killer.teamKey] = headcount[killer.teamKey]! + 1;
  }

  @override
  Future<void> onLoad() async {
    await images.load(assetPath);
    for (final teamKey in TeamKey.values) {
      for (int i = 0; i < playerPerTeam; i++) {
        spawnCharacter(teamKey);
      }
    }

    add(DisplayComponent(headcount: headcount));
  }

  Vector2 get randomPosition {
    final x = _rand.nextDouble() * size.x;
    final y = _rand.nextDouble() * size.y;
    return Vector2(x, y);
  }

  List<CharacterComponent> filterOpponents(TeamKey teamKey) {
    return characters.entries
        .where((element) => element.key != teamKey)
        .map((e) => e.value)
        .fold([], (previousValue, element) {
      previousValue.addAll(element.values);
      return previousValue;
    });
  }
}
