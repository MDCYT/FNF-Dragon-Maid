package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;

class ArtThing extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var arts:FlxSprite;

	public function new(x:Float, y:Float, artNum:Int = 0)
	{
        super(x, y);
		arts = new FlxSprite().loadGraphic(Paths.image('artBook/art' + artNum)); //recopila las imagenes
		add(arts);
	}

    override function update(elapsed:Float)
	{
		super.update(elapsed);
    }
}