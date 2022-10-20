package ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class MaidLight extends FlxSprite{
    var tween:FlxTween;
    public var isActive:Bool = false;
  public function new(x:Float, y:Float){
    super(x,y);

    frames = Paths.getSparrowAtlas('light');
    animation.addByPrefix('DOWN', 'DOWN', 24, false);
    animation.addByPrefix('LEFT', 'LEFT', 24, false);
    animation.addByPrefix('UP', 'UP', 24, false);
    animation.addByPrefix('RIGHT', 'RIGHT', 24, false);
    alpha = 0;

    updateHitbox();
  }

  public function daEffect(arrow:String){
    isActive = true;
    alpha = 0.4;
    switch(arrow)
    {
        case 'singDOWN':
            animation.play('DOWN');
        case 'singUP':
            animation.play('UP');
        case 'singRIGHT':
            animation.play('RIGHT');
        case 'singLEFT':
            animation.play('LEFT');
    }
  }

  public function outFx(){
    if(tween != null){tween.active = false;}
      tween = FlxTween.tween(this, {alpha: 0}, 0.5, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween){
        isActive = false;
      }});
  }

  override function update(elapsed:Float){

    super.update(elapsed);
  }
}
