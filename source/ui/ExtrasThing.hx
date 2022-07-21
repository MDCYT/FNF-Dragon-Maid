package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class ExtrasThing extends FlxSprite
{
	public var targetY:Float = 0;

	public function new(x:Float, y:Float, option:String)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('extraState/options/' + option);
        animation.addByPrefix('off', option + ' off', 24, true);
		animation.addByPrefix('on', option + ' on', 24, true);
        animation.play('off');
		//scale.set(1.2, 1.2);
		updateHitbox();
		antialiasing = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
