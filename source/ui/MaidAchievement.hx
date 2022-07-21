package ui;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import states.*;

class MaidAchievement extends FlxSpriteGroup {
  public var rectangle:FlxSprite;
  public var title:FlxText;
  public var desc:FlxText;
  public var achievements:Array<Dynamic> = [  
    ['Dragon Hunt Unlocked', 'You can now find it in the minigames menu', 'dragon'],
    ['YanKenPo Unlocked', 'You can now find it in the minigames menu', 'yanken'],
    ['Chaos Unlocked', 'You have managed to beat the harmony difficulty, you can now play in chaos difficulty', 'harmony'],
    ['Master Dragon', 'You have managed to beat the chaos difficulty, extra songs are now available in the store', 'chaos'],
    ['???', 'dragon.bat', 'secret'],
    ['???', ' You have won the secret song in Freeplay', 'secret'],
    ['Master Hunter', 'You have managed to find the golden dragon and shoot it', 'goldDragon']
  ];
  
  public function new(x:Float, y:Float, num:Int = 0){
    super(x,y);

    var name:Array<String> = achievements[num];

    rectangle = new FlxSprite().loadGraphic(Paths.image('achievement/' + name[2]));
    rectangle.updateHitbox();
    rectangle.antialiasing = true;
    add(rectangle);

    title = new FlxText(116, 30, 400, name[0]);
    title.setFormat(Paths.font('titleAchievement.otf'), 22, FlxColor.WHITE, RIGHT);
    add(title);

    desc = new FlxText(145, 67, 370, name[1]);
    desc.setFormat(Paths.font('descAchievement.ttf'), 19, FlxColor.WHITE, RIGHT);
    add(desc);

  }

  override function update(elapsed:Float){

    super.update(elapsed);
  }
}
