package ui;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.FlxG;
import states.PlayState;

class ScoreResults extends FlxSpriteGroup 
{
	public var grpMenuShit:FlxSpriteGroup;
    var bg:FlxBackdrop;
    public function new(x:Float, y:Float, score:Int, accuracy:Float, sick:Int, song:String)
    {
        super(x,y);

        bg = new FlxBackdrop(Paths.image('mainMenu/menuBg'), 10, 0, true, false);
		bg.velocity.set(-150, 0);
		add(bg);
    }


    override function update(elapsed:Float)
    {

        super.update(elapsed);
    }
}