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

class DragonBar extends FlxSpriteGroup {
  public var bg2:FlxSprite;
  public var bar2:FlxBar;
  public var smooth:Bool = false;
  public var downScroll:Bool = false;

  public var value:Float = 1;

  var display:Float = 1;
  var instance:FlxBasic;
  var property:String;
  public function new(x:Float,y:Float,player1:String,player2:String,?instance:FlxBasic,?property:String,min:Float=0,max:Float=2,baseColor:FlxColor=0xFFFF0000,secondaryColor:FlxColor=0xFF66FF33){
    super(x,y);
    if(property==null || instance==null){
      property='value';
      instance=this;
    }

    this.instance=instance;
    this.property=property;
    display = Reflect.getProperty(instance,property);

    bg2 = new FlxSprite(0, 0).loadGraphic(CoolUtil.getBitmap(Paths.image('bad/dragonBar','shared')));

    bar2 = new FlxBar(bg2.x + 8, bg2.y + 7, RIGHT_TO_LEFT, 564, 19, this, 'display', min, max);
		bar2.createFilledBar(0xFFFF2900, 0xFFFFFFFF);
    
    add(bar2);
    add(bg2);
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
    var percent = bar2.percent;
    var opponentPercent = 100-bar2.percent;

    super.update(elapsed);

  }
}
