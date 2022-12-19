import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HpBarComponent extends PositionComponent {
  final Paint _paint;
  final Paint _backgroundPaint;
  final double maxHp;
  double currentHp;

  HpBarComponent({required this.currentHp, required this.maxHp})
      : _paint = Paint()..color = Colors.green,
        _backgroundPaint = Paint()..color = Colors.black {
    size = Vector2(100, 20);
    anchor = Anchor.bottomCenter;
  }

  @override
  void render(Canvas canvas) {
    final maxHpRect = size.toRect();
    final currentHpRect = Vector2(size.x * currentHp / maxHp, size.y).toRect();
    canvas.drawRect(maxHpRect, _backgroundPaint);
    canvas.drawRect(currentHpRect, _paint);
  }
}
