package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class MainThing extends FlxSprite
{
	public function new(x:Float, y:Float, options:String)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('mainMenu/option/' + options);
		animation.addByPrefix('off', options + " Off", 24);
		animation.addByPrefix('on', options + " On", 24);
		animation.play('off');
		scale.set(0.7, 0.7);
		antialiasing = true;
		updateHitbox();
	}
    
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
