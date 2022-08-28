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

class MaidSpecials extends FlxSprite {

    var daSpecial:String = '';

  public function new(x:Float, y:Float, special:String = 'bfIdle'){

    super(x,y);

    daSpecial = special;

    frames = Paths.getSparrowAtlas('mainMenu/specialsObjectsPlayer');
    animation.addByPrefix('obj', special, 24, false);
    animation.play('obj');
    antialiasing = true;
    updateHitbox();
 
  }

  function goSpecial(obj:String) {

    switch(obj){
        
        case 'bfIdle':
            
    }

  }

  override function update(elapsed:Float){

    super.update(elapsed);

  }
}
