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

class BfBar extends FlxSpriteGroup {
  public var bg:FlxSprite;
  public var bar:FlxBar;
  public var smooth:Bool = false;
  public var downScroll:Bool = false;
  public var value:Float = 1;
  public var life:Int = PlayState.lifes;

  var display:Float = 1;
  var instance:FlxBasic;
  var property:String;
  public function new(x:Float,y:Float,?instance:FlxBasic,?property:String,min:Float=0,max:Float=2){
    super(x,y);
    if(property==null || instance==null){
      property='value';
      instance=this;
    }

    this.instance=instance;
    this.property=property;
    display = Reflect.getProperty(instance,property);

    bg = new FlxSprite();
    bg.frames = Paths.getSparrowAtlas('bad/bfBar', 'shared');
    bg.animation.addByPrefix('3', 'bfBar3');
    bg.animation.addByPrefix('2', 'bfBar2');
    bg.animation.addByPrefix('1', 'bfBar1');
    bg.animation.play('' + life);
    bg.updateHitbox();

    bar = new FlxBar(bg.x + 9, bg.y + 70, RIGHT_TO_LEFT, 367, 31, this, 'display', min, max);
    bar.createFilledBar(0xFF9C0000, 0xFF00AEFF);

    add(bar);
    add(bg);
  }
  public function beatHit(curBeat:Float){

  }

  override function update(elapsed:Float){
    var num = Reflect.getProperty(instance,property);
    if(smooth){
      display = FlxMath.lerp(display,num,Main.adjustFPS(.2));
      if(Math.abs(display-num)<.1){
        display=num;
      }
    }else{
      display=num;
    }

    var percent = bar.percent;
    var opponentPercent = 100-bar.percent;
  
    super.update(elapsed);

  }
}
