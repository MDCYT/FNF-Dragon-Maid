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

class KillBar extends FlxSpriteGroup 
{
    public var bg:FlxSprite;
    public var altBar:FlxSprite;
    public var overlap:FlxSprite;
    public var ind:FlxSprite;
    public var tween:FlxTween;
    public var defaultTime:Float = 0.7;

    public function new(x:Float, y:Float)
    {
        super(x,y);

        altBar = new FlxSprite().loadGraphic(Paths.image('maidDragon/utils/altBar', 'shared'));
        altBar.updateHitbox();

        overlap = new FlxSprite(altBar.x, altBar.y).loadGraphic(Paths.image('maidDragon/utils/overlap', 'shared'));
        overlap.scale.x += 1.7;
        overlap.updateHitbox();

        ind = new FlxSprite(altBar.x, altBar.y - altBar.height).loadGraphic(Paths.image('maidDragon/utils/ind', 'shared'));
        ind.updateHitbox();

        add(altBar);
        add(overlap);
        add(ind);
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

    public function moveEvent()
    {
        tween.active = false;

        new FlxTimer().start(0.2, function(tmr:FlxTimer)
        {
            PlayState.noSpam = false;
            PlayState.killerDrown = true;
            moveIn(Std.random(Std.int(altBar.width)), 1);
        });
    }

    public function failEvent()
    {
        //tween.cancel();
        ind.x = altBar.x;

        moveIn(Std.random(Std.int(altBar.width)), 2);
    }

    override function update(elapsed:Float)
    {
        ind.updateHitbox();
        overlap.updateHitbox();

        if (overlap.scale.x <= 0.3)
        {
            FlxTween.color(altBar, 2, altBar.color, FlxColor.RED, {type: PINGPONG});
        }

        super.update(elapsed);
    }
}