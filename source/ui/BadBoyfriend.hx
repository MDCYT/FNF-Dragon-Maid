package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import states.*;

class BadBoyfriend extends FlxSprite
{
    var jumpi:Int = 30;
    public var uh:Int = 2000;

    public function new(x:Float, y:Float)
    {   
        super(x, y);

        frames = Paths.getSparrowAtlas('bad/bf');
        animation.addByPrefix('walk', 'walk', 24, true);
        animation.addByPrefix('jump', 'jump', 24, false);
        animation.play('walk');

        setGraphicSize(Std.int(this.width / 4));
        updateHitbox();
        antialiasing = false;
        flipX = true;

        acceleration.y = uh;
    }

    override function update(elapsed:Float)
    {
    
        super.update(elapsed);
    }
}