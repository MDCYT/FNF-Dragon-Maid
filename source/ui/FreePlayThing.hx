package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;

class FreePlayThing extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var song:FlxSprite;

	public function new(x:Float, y:Float, songNum:String = '')
	{
		super(x, y);
		if (songNum != 'killer-scream'){
			song = new FlxSprite().loadGraphic(Paths.image('freeTitle/' + songNum));
	    	song.y = -300;
        	song.x += 780;
			add(song);
		}
		else{
			song = new FlxSprite();
			song.frames = Paths.getSparrowAtlas('freeTitle/' + songNum);
			song.animation.addByPrefix('lock', songNum + '-lock');
			song.animation.addByPrefix('unlock', songNum + '-unlock');
			if (!FlxG.save.data.killer){
				song.animation.play('lock');
			}
			else song.animation.play('unlock');
			trace(songNum);
			song.updateHitbox();
			song.y = -300;
        	song.x += 780;
			add(song);
		}

		song.antialiasing = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!FlxG.save.data.killer){
			song.animation.play('lock');
		}
		else song.animation.play('unlock');
		
		y = FlxMath.lerp(y, (targetY * 120) + 480, 0.17);
	}
}
