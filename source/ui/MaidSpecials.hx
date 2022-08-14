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

class MaidSpecials extends FlxSpriteGroup {

    var obj:FlxSprite;
    var special:String = '';

  public function new(x:Float, y:Float, special:String = 'bfIdle'){

    super(x,y);

    special = special;

    obj = new FlxSprite();
    obj.frames = Paths.getSparrowAtlas('mainMenu/specialsObjects');
    obj.animation.addByPrefix('obj', special, 24, false);
    obj.animation.play('obj');
    add(obj);
 
  }

  function goSpecial(obj:String = special) {

    switch(special){
        
        case 'bfIdle':
            
    }

  }

  override function update(elapsed:Float){

    super.update(elapsed);

  }
}
