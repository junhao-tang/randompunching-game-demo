import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:targetmechanism/game.dart';
import 'package:targetmechanism/hpbar.dart';
import 'package:targetmechanism/types.dart';

class CharacterComponent extends SpriteAnimationGroupComponent<CharacterStatus>
    with HasGameRef<DummyGame> {
  static const double distanceTolerance = 50;
  static const Size designComponentSize = Size(224, 224);

  final String id;
  final CharacterStats stats;
  final TeamKey teamKey;
  final VoidCallback? removeCallback;
  CharacterStatus _status;
  double _hp;

  late final HpBarComponent _hpBarComponent;

  CharacterComponent? _target;
  Vector2? _destination;

  CharacterComponent({
    required super.position,
    required this.stats,
    required this.teamKey,
    required this.id,
    this.removeCallback,
  })  : _hp = stats.maxHp,
        _status = CharacterStatus.idle;

  @override
  Future<void> onLoad() async {
    size = Vector2(designComponentSize.width, designComponentSize.height);
    anchor = Anchor.center;
    current = _status;

    initializeTeamColour();
    initializeAdditionalComponents();
    initializeAnimation();
  }

  void initializeTeamColour() {
    add(
      ColorEffect(
        teamKey == TeamKey.team1 ? Colors.blue : Colors.red,
        const Offset(0.5, 0.8),
        EffectController(duration: 1.5),
      ),
    );
  }

  void initializeAdditionalComponents() {
    _hpBarComponent = HpBarComponent(currentHp: _hp, maxHp: stats.maxHp)
      ..position = Vector2(size.x / 2, 30);
    add(_hpBarComponent);
    // add(CharacterInfoComponent(data: this)
    //   ..size = size
    //   ..position = Vector2(0, 30));
  }

  void initializeAnimation() {
    final image = gameRef.images.fromCache(stats.assetPath);

    final deathAnimation = SpriteAnimation.fromFrameData(
        image, stats.deathAnimationData.spriteAnimationData)
      ..onComplete = () {
        gameRef.removeCharacter(this);
      };

    final attackAnimation = SpriteAnimation.fromFrameData(
        image, stats.attackAnimationData.spriteAnimationData)
      ..onStart = () {
        if (target != null) {
          _adjustSpriteFacing(target!.position);
        }
      };
    attackAnimation.stepTime =
        stats.attackSpeed / attackAnimation.frames.length;
    attackAnimation.onFrame = (int lastFrameIndex) => (int i) {
          if (_target == null || _target!.status == CharacterStatus.dead) {
            _target = null;
            _updateStatus(CharacterStatus.idle);
            return;
          }
          final target = _target!;
          if (target.position.distanceTo(position) > stats.attackRange) {
            _updateStatus(CharacterStatus.attackmove);
            return;
          }
          if (lastFrameIndex == i) {
            _target?.receiveDamage(stats.attack, this);
          }
        }(attackAnimation.frames.length - 1);

    animations = stats.animationsData.map<CharacterStatus, SpriteAnimation>(
      (key, value) => MapEntry(
        key,
        SpriteAnimation.fromFrameData(image, value.spriteAnimationData),
      ),
    );
    animations![CharacterStatus.dead] = deathAnimation;
    animations![CharacterStatus.attack] = attackAnimation;
  }

  @override
  void update(double dt) {
    super.update(dt);
    switch (_status) {
      case CharacterStatus.attack:
        // relative to animation
        break;
      case CharacterStatus.move:
        _updateMove();
        break;
      case CharacterStatus.attackmove:
        _updateAttackMove();
        break;
      case CharacterStatus.idle:
        final target = _autoSelectTarget();
        if (target != null) orderAttackTarget(target);
        break;
      default:
        break;
    }
  }

  void orderAttackTarget(CharacterComponent target) {
    _target = target;
    _updateStatus(CharacterStatus.attack);
  }

  void orderMoveTo(Vector2 destination) {
    _destination = destination;
    _updateStatus(CharacterStatus.move);
  }

  // return: bool whether killed
  bool receiveDamage(double damage, CharacterComponent dealer) {
    final finalDamage = damage;
    _hp = max(0, _hp - finalDamage);
    _hpBarComponent.currentHp = _hp;
    // print("damage from: ${dealer.id}, $damage $_hp/${stats.maxHp}");

    if (_hp == 0) {
      _killed(dealer);
      return true;
    }
    return false;
  }

  void _killed(CharacterComponent killer) {
    gameRef.announceKill(killer, this);
    _updateStatus(CharacterStatus.dead);
    priority = -1;
  }

  void _updateMove() {
    if (_destination == null ||
        _destination!.distanceTo(position) <= distanceTolerance) {
      _destination = null;
      _updateStatus(CharacterStatus.idle);
      return;
    }
    _adjustSpriteFacing(_destination!);
    position.moveToTarget(_destination!, stats.movementSpeed);
  }

  void _updateAttackMove() {
    if (_target == null || _target!.status == CharacterStatus.dead) {
      _target = null;
      _updateStatus(CharacterStatus.idle);
      return;
    }
    _adjustSpriteFacing(_target!.position);
    if (_target!.position.distanceTo(position) <= stats.attackRange) {
      _updateStatus(CharacterStatus.attack);
      return;
    }
    position.moveToTarget(_target!.position, stats.movementSpeed);
  }

  void _adjustSpriteFacing(Vector2 targetVector) {
    final facedRightAngle = Vector2(1, 0);

    final angle = facedRightAngle.angleTo(targetVector - position);
    if (angle >= pi / 2 && angle <= pi * 3 / 2) {
      if (!isFlippedHorizontally) {
        _reverseFlipComponents();
        flipHorizontally();
      }
    } else if (isFlippedHorizontally) {
      flipHorizontally();
      _reverseFlipComponents();
    }
  }

  void _reverseFlipComponents() {
    // revert flip. or make sprite as child, then flip only the sprite
    _hpBarComponent.flipHorizontally();
  }

  void _updateStatus(CharacterStatus newStatus) {
    if (newStatus == _status) return;
    _status = newStatus;
    current = animations![_status] != null ? _status : CharacterStatus.idle;
  }

  CharacterComponent? _autoSelectTarget() {
    // Can take in a fn to customize selection behavior
    final opponents = gameRef.filterOpponents(teamKey);
    if (opponents.isEmpty) return null;
    print(
        "$id $teamKey seeking opponent, ${opponents.map((e) => '${id.substring(0, 8)}:${e.status}')}");

    // random target
    opponents.shuffle();
    for (final opponent in opponents) {
      if (opponent.status != CharacterStatus.dead) {
        return opponent;
      }
    }
    return null;
  }

  CharacterStatus get status => _status;
  double get hp => _hp;
  CharacterComponent? get target => _target;
  Vector2? get destination => _destination;
}
