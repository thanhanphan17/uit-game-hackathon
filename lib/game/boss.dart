// ignore_for_file: avoid_print

import 'package:dino_run/game/bullet_manager.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '/game/dino_run.dart';
import '/models/boss_data.dart';
import 'bullet.dart';
import 'LifeBar.dart';

// This represents an enemy in the game world.
class Boss extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<DinoRun> {
  // The data required for creation of this enemy.

  final BossData bossData;

  final Timer _switchDirection = Timer(
    1,
    repeat: true,
  );
  late double positionY;
  late BulletManager _bulletCreation;

  bool _moveUp = true;

  final Timer _shootCountDown = Timer(
    0.75,
    repeat: true,
  );

  Boss(this.bossData) {
    animation = SpriteAnimation.fromFrameData(
      bossData.image,
      SpriteAnimationData.sequenced(
        amount: bossData.nFrames,
        stepTime: bossData.stepTime,
        textureSize: bossData.textureSize,
      ),
    );
  }

  late LifeBar lifeBar;

  createLifeBar() {
    lifeBar = LifeBar.initData(size,
        size: Vector2(40, 5), placement: LifeBarPlacement.left);
    //
    // add all lifebar element to the children of the Square instance
    add(lifeBar);
  }

  @override
  Future<void> onMount() async {
    createLifeBar();

    // Reduce the size of enemy as they look too
    // big compared to the dino.
    _bulletCreation = BulletManager();
    size *= 0.6;
    _switchDirection.onTick = () {
      _moveUp = !_moveUp;
    };

    print('positionx: ${position.x}');

    _shootCountDown.onTick = () {
      positionY = position.y;
      add(_bulletCreation.spawnBullet(
          40,
          50,
          gameRef.images.fromCache('Bullet/fire_bullet.png'),
          Vector2(100, 30),
          550));
    };

    // Add a hitbox for this enemy.
    add(
      RectangleHitbox.relative(
        Vector2.all(0.8),
        parentSize: size,
        position: Vector2(size.x * 0.2, size.y * 0.2) / 2,
      ),
    );
    super.onMount();
  }

  @override
  void update(double dt) {
    // position.x -= bossData.speedX * dt;

    if (_moveUp) {
      position.y -= bossData.speedY * dt;
    } else {
      position.y += bossData.speedY * dt;
    }

    // Remove the enemy and increase player score
    // by 1, if enemy has gone past left end of the screen.
    if (position.x < -bossData.textureSize.x) {
      removeFromParent();
      gameRef.playerData.currentScore += 1;
    }

    _shootCountDown.update(dt);
    _switchDirection.update(dt);
    // lifeBarElements.update(dt);
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bullet) {
      // print("hp");
      lifeBar.decrementCurrentLifeBy(10);
    }
    super.onCollision(intersectionPoints, other);
  }
}
