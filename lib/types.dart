import 'dart:ui';

import 'package:flame/components.dart';

enum CharacterStatus {
  idle,
  move,
  attack,
  attackmove,
  dead,
}

enum TeamKey {
  team1,
  team2,
}

class AnimationData {
  final double stepTime;
  final int amount;
  final Offset framePosition;
  final Size frameSize;
  final bool loop;
  final int? amountPerRow;

  const AnimationData({
    required this.stepTime,
    required this.amount,
    required this.framePosition,
    required this.frameSize,
    this.loop = false,
    this.amountPerRow,
  });

  SpriteAnimationData get spriteAnimationData {
    return SpriteAnimationData.sequenced(
      amount: amount,
      stepTime: stepTime,
      amountPerRow: amountPerRow,
      textureSize: Vector2(frameSize.width, frameSize.height),
      texturePosition: Vector2(framePosition.dx * frameSize.width,
          framePosition.dy * frameSize.height),
      loop: loop,
    );
  }
}

class AttackAnimationData extends AnimationData {
  // not important, adjusted by stats.attackspeed
  const AttackAnimationData({
    required super.amount,
    required super.framePosition,
    required super.frameSize,
    super.amountPerRow,
    super.loop = false,
  }) : super(stepTime: 1);
}

class CharacterStats {
  final double maxHp;
  final double attack;
  final double movementSpeed;
  final double attackSpeed;
  final double attackRange;
  final Map<CharacterStatus, AnimationData> animationsData;
  final AttackAnimationData attackAnimationData;
  final AnimationData deathAnimationData;
  final String assetPath;

  const CharacterStats({
    required this.maxHp,
    required this.attack,
    required this.movementSpeed,
    required this.attackRange,
    required this.assetPath,
    required this.animationsData,
    required this.attackAnimationData,
    required this.deathAnimationData,
    required this.attackSpeed,
  });
}
