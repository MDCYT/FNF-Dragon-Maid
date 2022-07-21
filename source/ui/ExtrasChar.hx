package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class ExtrasChar extends FlxSprite
{
	public var targetY:Float = 0;

	public function new(x:Float, y:Float, char:String)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('extraState/char/' + char);
        animation.addByPrefix('idle', char, 24, true);
        animation.play('idle');
		updateHitbox();
		screenCenter();
		antialiasing = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
