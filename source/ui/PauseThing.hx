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

class PauseThing extends FlxSpriteGroup 
{

    public function new(x:Float, y:Float, state:Int = 0)
    {
        super(x,y);

    }

    public function moveIn(initPos:Int, open:Int)
    {
        switch(open)
        {
            case 0:
                overlap.x = altBar.x + initPos;
                ind.x = altBar.x;
                tween = FlxTween.tween(ind, {x: ind.x + altBar.width}, defaultTime, {type: PINGPONG});
        
            case 1:
                overlap.x = altBar.x + initPos;
                tween.active = true;
            case 2:
                defaultTime -= 0.005;

                if(defaultTime <= 0.3)
                    defaultTime = 0.35;

                tween.duration = defaultTime;
                overlap.scale.x -= 0.02;
                PlayState.drownScale += 0.00001;
                //tween = FlxTween.tween(ind, {x: ind.x + altBar.width}, defaultTime, {type: PINGPONG});

        }
    }


    override function update(elapsed:Float)
    {

        super.update(elapsed);
    }
}