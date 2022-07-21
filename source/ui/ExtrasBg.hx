package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class ExtrasBg extends FlxSprite
{
	public var targetY:Float = 0;

	public function new(x:Float, y:Float, option:String)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('extraState/bg/' + option + 'Bg');
        animation.addByPrefix('bg', 'bg', 24, true);
        animation.play('bg');
		updateHitbox();
		screenCenter();
		antialiasing = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
