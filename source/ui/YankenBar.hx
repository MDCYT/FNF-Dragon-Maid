package ui;

import flixel.FlxSprite;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import states.*;

class YankenBar extends FlxSpriteGroup {
  public var bg:FlxSprite;
  public var bar:FlxBar;
  public var bgBar:FlxSprite;
  public var selecHands:FlxSpriteGroup;
  public var drown:Bool = false;
  public var bgs:FlxSprite;

  public var time:Float = 1;

  public function new(x:Float, y:Float)
  {
    super(x,y);

    bgs = new FlxSprite().loadGraphic(CoolUtil.getBitmap(Paths.image('yankenPo/black')));
    bgs.screenCenter();

    bgBar = new FlxSprite(0, 40).loadGraphic(CoolUtil.getBitmap(Paths.image('yankenPo/barra')));
    bgBar.screenCenter(X);

    bar = new FlxBar(0, 50, RIGHT_TO_LEFT, Std.int(bgBar.width - 20), Std.int(bgBar.height - 20), this, 'time', 0, 1);
    bar.createFilledBar(FlxColor.WHITE, 0xFFffd800);
    bar.screenCenter(X);

    add(bgs);
    add(bgBar);
    add(bar);

    selecHands = new FlxSpriteGroup();

    for (i in 0...YankenObjects.daHands.length)
    {
      var hands:FlxSprite = new FlxSprite(0, 0);
      hands.frames = Paths.getSparrowAtlas('yankenPo/hands');
      hands.animation.addByPrefix('idle', YankenObjects.daHands[i] + ' off', 24, false);
      hands.animation.addByPrefix('selected', YankenObjects.daHands[i] + ' on', 24, false);
      hands.animation.play('idle');
      hands.ID = i;
      hands.setGraphicSize(Std.int(hands.width * 5));
      hands.updateHitbox();

      switch(i)
      {
        case 0:
          hands.setPosition(267, 277);
        case 1:
          hands.setPosition(565, 265);
        case 2:
          hands.setPosition(858, 288);
      }
      hands.antialiasing = false;
                    
      selecHands.add(hands);
    }

    add(selecHands);
  }

  var daObject:Int = 0;

  override function update(elapsed:Float)
  {

    if (drown)
    {
      time -= 0.001;
    }
    
    super.update(elapsed);

  }
}
