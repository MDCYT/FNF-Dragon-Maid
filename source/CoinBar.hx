package;

import flixel.FlxBasic;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxColor;

class CoinBar {
  
  public static function purchase(presio:Int, event:String){
    if (FlxG.save.data.coin >= presio){
      FlxG.save.data.coin -= presio;
      FlxG.sound.play(Paths.sound('purchase'));
      checkOut(event);
    }
    else if (FlxG.save.data.coin < presio){
      FlxG.sound.play(Paths.sound('nop'));
    }
  }

  public static function checkOut(event:String){

    FlxG.camera.flash(FlxColor.WHITE, 1);

    switch (event){
      
      case 'killers':
        FlxG.save.data.killer = true;
    }
  }
}
